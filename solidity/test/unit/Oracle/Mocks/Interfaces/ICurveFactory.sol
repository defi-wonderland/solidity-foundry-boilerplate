pragma solidity ^0.8.19;

interface ICurveFactory {
  function find_pool_for_coins(address _from, address _to) external view returns (address _pool);
}
