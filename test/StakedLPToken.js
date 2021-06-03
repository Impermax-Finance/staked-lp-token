const StakedLpToken = artifacts.require("StakedLPToken01");
const MockERC20 = artifacts.require("MockERC20");
const StakingRewards = artifacts.require("StakingRewards");
const UniswapV2Router02 = artifacts.require("UniswapV2Router02");
const UniswapV2Factory = artifacts.require("UniswapV2Factory");
const UniswapV2Pair = artifacts.require("UniswapV2Pair");
const StakedLPTokenFactory = artifacts.require("StakedLPTokenFactory01");

const chai = require("chai");
const chaiAsPromised = require("chai-as-promised");
chai.use(chaiAsPromised);
const { expect, assert } = chai;
const { time, BN } = require("@openzeppelin/test-helpers");

const toWei = (amount, decimal = 18) => {
  return new BN(amount).mul(new BN(10).pow(new BN(decimal)));
};

contract("StakedLpToken Test", function (accounts) {
  const [alice, bob, john] = accounts;

  let stakedLpToken, stakingRewards, rewardsToken, underlyingToken;
  let stakedLpTokenFactory;
  let token0, token1, weth;
  let uniswapV2Router, uniswapV2Factory;
  let bobBalanceBefore, bobBalanceAfter;

  before("deploying contracts", async () => {
    rewardsToken = await MockERC20.new("Rewards Token", "RTK");
    weth = await MockERC20.new("Wrapped Eth", "WETH");

    await rewardsToken.mint(john, toWei(1000000));

    token0 = rewardsToken;
    token1 = weth;

    await token0.mint(alice, toWei(100000));
    await token1.mint(alice, toWei(100000));

    await token0.mint(bob, toWei(100000));
    await token1.mint(bob, toWei(100000));

    console.log("Token0 deployed at ", token0.address);
    console.log("Token1 deployed at ", token1.address);

    uniswapV2Factory = await UniswapV2Factory.new(alice);
    console.log("UniswapV2Factory deployed at ", uniswapV2Factory.address);

    await uniswapV2Factory.createPair(token0.address, token1.address);

    const pair = await uniswapV2Factory.getPair(token0.address, token1.address);
    console.log("Created pair at ", pair);

    stakingRewards = await StakingRewards.new(john, rewardsToken.address, pair);
    console.log("Staking Rewards deployed at ", stakingRewards.address);
    await rewardsToken.transfer(stakingRewards.address, toWei(1000000), { from: john });

    const rewardBalance = await rewardsToken.balanceOf(stakingRewards.address);
    console.log("Reward token balance of stakingRewards contract is ", rewardBalance.toString());

    await stakingRewards.notifyRewardAmount(rewardBalance, 60 * 60 * 24 * 15, { from: john }); //reward duration is 15 days

    uniswapV2Router = await UniswapV2Router02.new(uniswapV2Factory.address, weth.address);
    console.log("UniswapV2Router deployed at ", uniswapV2Router.address);

    await token0.approve(uniswapV2Router.address, toWei(10000));
    await token1.approve(uniswapV2Router.address, toWei(10000));

    await uniswapV2Router.addLiquidity(
      token0.address,
      token1.address,
      toWei(10000),
      toWei(10000),
      0,
      0,
      alice,
      162182626600
    );

    await token0.approve(uniswapV2Router.address, toWei(40000), { from: bob });
    await token1.approve(uniswapV2Router.address, toWei(40000), { from: bob });

    await uniswapV2Router.addLiquidity(
      token0.address,
      token1.address,
      toWei(40000),
      toWei(40000),
      0,
      0,
      bob,
      162182626600,
      { from: bob }
    );

    underlyingToken = await UniswapV2Pair.at(pair);

    stakedLpTokenFactory = await StakedLPTokenFactory.new(uniswapV2Router.address, weth.address);
    console.log("StakedLpTokenFactory deployed at ", stakedLpTokenFactory.address);
  });

  it("Before. CreateStakedLptoken should work", async () => {
    await stakedLpTokenFactory.createStakedLPToken(stakingRewards.address);
    const allLpTokenLength = await stakedLpTokenFactory.allStakedLPTokenLength();
    assert(allLpTokenLength.toString() === "1", "createStakedLPToken error");
  });

  it("1. StakedLptoken Mint Test", async () => {
    const lpToken = await stakedLpTokenFactory.getStakedLPToken(stakingRewards.address);
    stakedLpToken = await StakedLpToken.at(lpToken);
    console.log("Staked Lp Token created at ", stakedLpToken.address);

    console.log("============== Alice mint ===========");
    const aliceBalanceBefore = await underlyingToken.balanceOf(alice);
    console.log("Alice's underlying token balance is ", aliceBalanceBefore.toString());

    await underlyingToken.transfer(stakedLpToken.address, aliceBalanceBefore);

    console.log("==== Alice's staking is being permanent locked ======");
    await stakedLpToken.mint(alice);

    const aliceLpBalance = await stakedLpToken.balanceOf(alice);

    const minimum_liquidity = await stakedLpToken.MINIMUM_LIQUIDITY();

    expect(aliceBalanceBefore.toString()).to.equal(aliceLpBalance.add(minimum_liquidity).toString());

    console.log("============== Bob mint ===========");
    bobBalanceBefore = await underlyingToken.balanceOf(bob);
    console.log("Bob's underlying token balance is ", bobBalanceBefore.toString());

    await underlyingToken.transfer(stakedLpToken.address, bobBalanceBefore, { from: bob });
    console.log(
      "StakeLpToken's underlying token balance is ",
      (await underlyingToken.balanceOf(stakedLpToken.address)).toString()
    );
    await stakedLpToken.mint(bob, { from: bob });

    const stakedBobBalance = await stakedLpToken.balanceOf(bob);
    console.log("Bob's stakedLptoken balance is ", stakedBobBalance.toString());
    expect(stakedBobBalance.toString()).to.equal(bobBalanceBefore.toString());
  });

  it("2. StakedLptoken Redeem & Reinvest Test", async () => {
    await time.increase(60 * 60 * 24 * 15);
    console.log("=========== After 15 days : Reinvest from bob =========");
    await stakedLpToken.reinvest({ from: bob });

    console.log("rewardRate => %s\n", (await stakingRewards.rewardRate()).toString());
    console.log("totalSupply => %s\n", (await stakingRewards.totalSupply()).toString());
    console.log("rewardperToken => %s\n", (await stakingRewards.rewardPerToken()).toString());

    await time.increase(60 * 60 * 24 * 15);
    console.log("=========== After 15 days =========");
    console.log("Bob's underlying balance before is ", (await underlyingToken.balanceOf(bob)).toString());
    const bobLpBalance = await stakedLpToken.balanceOf(bob);
    await stakedLpToken.transfer(stakedLpToken.address, bobLpBalance, { from: bob });
    await stakedLpToken.redeem(bob, { from: bob });
    bobBalanceAfter = await underlyingToken.balanceOf(bob);
    assert(bobBalanceAfter.gt(bobBalanceBefore), "reinvest error");
    console.log("Bob's underlying balance after is ", bobBalanceAfter.toString());
  });
});
