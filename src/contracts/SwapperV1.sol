// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// External Imports
import {Ownable} from '@openzeppelin/access/Ownable.sol';
import {IERC20} from '@openzeppelin/token/ERC20/IERC20.sol';

// Internal Imports
import {ISwapperV1} from 'interfaces/ISwapperV1.sol';

contract SwapperV1 is ISwapperV1, Ownable {
  /*///////////////////////////////////////////////////////////////
                            Storage
    //////////////////////////////////////////////////////////////*/

  /// @inheritdoc ISwapperV1
  address public immutable DEPOSITED_TOKEN;

  /// @inheritdoc ISwapperV1
  address public immutable SWAPPED_TOKEN;

  /// @inheritdoc ISwapperV1
  bool public swapped;

  /// @notice Mapping of user to swap info
  mapping(address user => SwapInfo swapInfo) private _userToSwapInfo;

  modifier onlyNotSwapped() {
    if (swapped) revert SwapperV1_SwapAlreadyExecuted();
    _;
  }

  /*///////////////////////////////////////////////////////////////
                            Constructor
    //////////////////////////////////////////////////////////////*/

  constructor(address _depositedToken, address _swappedToken) Ownable(msg.sender) {
    DEPOSITED_TOKEN = _depositedToken;
    SWAPPED_TOKEN = _swappedToken;
  }

  /*///////////////////////////////////////////////////////////////
                            External Functions
    //////////////////////////////////////////////////////////////*/

  /// @inheritdoc ISwapperV1
  function deposit(uint256 _amount) external payable onlyNotSwapped {
    SwapInfo storage _swapInfo = _userToSwapInfo[msg.sender];

    // Ensure funds are deposited to the swapper contract
    if (DEPOSITED_TOKEN == address(0)) {
      if (msg.value != _amount) revert SwapperV1_AmountMismatch();
    } else {
      // TODO: Can add IERC20Permit but not needed for now
      IERC20(DEPOSITED_TOKEN).transferFrom(msg.sender, address(this), _amount);
    }

    // Update the swap info
    _swapInfo.depositTokenAmount += _amount;

    emit TokensDeposited(msg.sender, _amount);
  }

  /// @inheritdoc ISwapperV1
  function swap() external onlyOwner onlyNotSwapped payable {

    uint256 _depositTokenBalance = _getTokenBalance(DEPOSITED_TOKEN);
  
    // Deposit tokens into contract
    if (SWAPPED_TOKEN == address(0)) {
      payable(msg.sender).transfer(msg.value);
    } else {
      IERC20(SWAPPED_TOKEN).transferFrom(msg.sender, address(this), _depositTokenBalance);
    }

    // Expect liquidity to be equal to the deposited token balance (1:1 swap)
    if (_depositTokenBalance != _getTokenBalance(SWAPPED_TOKEN)) {
      revert SwapperV1_NotEnoughLiquidity();
    }

    // Transfer the tokens to the owner
    if (DEPOSITED_TOKEN == address(0)) {
      payable(msg.sender).transfer(_depositTokenBalance);
    } else {
      IERC20(DEPOSITED_TOKEN).transfer(msg.sender, _depositTokenBalance);
    }

    swapped = true;
    emit TokensSwapped();
  }

  /// @inheritdoc ISwapperV1
  function withdrawDeposit() external onlyNotSwapped {
    SwapInfo storage _swapInfo = _userToSwapInfo[msg.sender];

    if (_swapInfo.depositTokenAmount == 0) revert SwapperV1_NoTokensToWithdraw();

    // Withdraw the tokens
    if (DEPOSITED_TOKEN == address(0)) {
      payable(msg.sender).transfer(_swapInfo.depositTokenAmount);
    } else {
      IERC20(DEPOSITED_TOKEN).transfer(msg.sender, _swapInfo.depositTokenAmount);
    }

    // Delete the swap
    delete _userToSwapInfo[msg.sender];

    // Emit the event
    emit DepositWithdrawn(msg.sender, _swapInfo.depositTokenAmount);
  }

  /// @inheritdoc ISwapperV1
  function withdraw() external {
    SwapInfo storage _swapInfo = _userToSwapInfo[msg.sender];

    if (_swapInfo.depositTokenAmount == 0) revert SwapperV1_NoTokensToWithdraw();

    if (_swapInfo.hasWithdrawn) revert SwapperV1_AlreadyWithdrawn();

    uint256 _swapTokenAmount = getSwapTokenAmount(msg.sender);

    // Withdraw the tokens
    if (SWAPPED_TOKEN == address(0)) {
      payable(msg.sender).transfer(_swapTokenAmount);
    } else {
      IERC20(SWAPPED_TOKEN).transfer(msg.sender, _swapTokenAmount);
    }

    // Update the swap info
    _swapInfo.hasWithdrawn = true;

    // Emit the event
    emit SwappedTokensWithdrawn(msg.sender, _swapTokenAmount);
  }

  /// @inheritdoc ISwapperV1
  function recieve() external payable {}

  /// @inheritdoc ISwapperV1
  function userToSwapInfo(address _user) external view returns (SwapInfo memory) {
    return _userToSwapInfo[_user];
  }

  /*///////////////////////////////////////////////////////////////
                            Public Functions
    //////////////////////////////////////////////////////////////*/

  /// @inheritdoc ISwapperV1
  function getSwapTokenAmount(address _user) public view returns (uint256) {
    SwapInfo memory _swapInfo = _userToSwapInfo[_user];
    if (_swapInfo.hasWithdrawn) return 0;
    /// @dev We can return deposit token amount (as this is a 1:1 swap) but this is a more flexible implementation
    return (_swapInfo.depositTokenAmount * _getTokenBalance(SWAPPED_TOKEN)) / _getTokenBalance(DEPOSITED_TOKEN);
  }

  /*///////////////////////////////////////////////////////////////
                            Internal Functions
    //////////////////////////////////////////////////////////////*/

  function _getTokenBalance(address _token) internal view returns (uint256) {
    if (_token == address(0)) {
      return address(this).balance;
    } else {
      return IERC20(_token).balanceOf(address(this));
    }
  }
}
