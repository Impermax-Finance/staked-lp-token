pragma solidity >=0.5.0;

// For: Radiant

interface IMultiFeeDistribution {
	function exit(bool claimRewards, address onBehalfOf) external;
}