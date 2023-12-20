pragma solidity ^0.8.19;

interface IStableSwap {
  function get_dy(int128 _i, int128 _j, uint256 _dx) external view returns (uint256 _dy);
  function coins(uint256 _i) external view returns (address _token);
}
