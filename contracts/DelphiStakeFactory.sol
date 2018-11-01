pragma solidity ^0.4.18;
import "./inherited/Proxy.sol";
import "./DelphiStake.sol";

contract DelphiStakeFactory {

  event StakeCreated(uint _stakeId, address _contractAddress);

  DelphiStake[] public stakes;

  address public masterCopy;

  /*
  @dev constructor function which sets the master copy of the stake contract
  @param _masterCopy the address where the template DelphiStake contract resides
  */
  constructor(address _masterCopy)
  public
  {
    masterCopy = _masterCopy;
  }

  /*
  @dev when creating a new Delphi Stake using a proxy contract architecture, a user must
  initialialize their stake, depositing their tokens
  @param _staker the address of the individual creating the stake
  @param _value the value of the stake in token units
  @param _token the address of the token being deposited
  @param _data a content hash of the relevant associated data describing the stake
  @param _claimDeadline the deadline for opening new cliams; the earliest moment that
  a stake can be withdrawn by the staker
  */
  function createDelphiStake(address _issuer, uint _value, ERC20 _token, string _data, uint _stakeReleaseTime)
  public
  {
    // Revert if the issuer is the 0 _contractAddress
    require(_issuer != address(0));

    // Revert if the specified value to stake cannot be transferred in
    require(_token.transferFrom(msg.sender, this, _value));

    address newStake = new Proxy(masterCopy);
    stakes.push(DelphiStake(newStake));

    // Approve for the stake's tokens to be transfered into the stake upon initialization
    _token.approve(newStake, _value);

    // Initialize the stake and set the staker address as the msg.sender
    stakes[stakes.length - 1].initDelphiStake(_issuer, _value, _token, _data, _stakeReleaseTime);

    emit StakeCreated(stakes.length - 1, stakes[stakes.length - 1]);
  }

  /*
  @dev Getter function to return the total number of stakes which have ever been created
  */
  function getNumStakes()
  public
  constant
  returns (uint)
  {
    return stakes.length;
  }

}
