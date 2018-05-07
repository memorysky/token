pragma solidity ^0.4.17;

import 'http://github.com/OpenZeppelin/zeppelin-solidity/contracts/token/ERC20/MintableToken.sol';
import 'http://github.com/OpenZeppelin/zeppelin-solidity/contracts/token/ERC20/PausableToken.sol';
import 'http://github.com/OpenZeppelin/zeppelin-solidity/contracts/math/SafeMath.sol';


contract SCToken is MintableToken, PausableToken{
	// Cheatsheet of inherit methods and events
	// function transferOwnership(address newOwner);
	// function allowance(address owner, address spender) constant returns (uint256);
	// function transfer(address _to, uint256 _value) returns (bool);
	// function transferFrom(address from, address to, uint256 value) returns (bool);
	// function approve(address spender, uint256 value) returns (bool);
	// function increaseApproval (address _spender, uint _addedValue) returns (bool success);
	// function decreaseApproval (address _spender, uint _subtractedValue) returns (bool success);
	// function finishMinting() returns (bool);
	// function mint(address _to, uint256 _amount) returns (bool);
	// event Approval(address indexed owner, address indexed spender, uint256 value);
	// event Mint(address indexed to, uint256 amount);
	// event MintFinished();
	// https://github.com/tokenstars/ace-token/blob/master/contracts/AceToken.sol
	/*Public variables of the token*/
	string public name="Sophon Capital Token";
	string public symbol="SCCT";
	string public standard="ERC20";	
	uint8 public decimals=18;

	/*Minting Constant*/
	uint256 public totalSupply=0;
	uint256 public INITIAL_SUPPLY = 5*(10**8)*(10**18);
	uint256 public ONE_PERCENT = INITIAL_SUPPLY/100;
	uint256 public TOKEN_SALE = 60 * ONE_PERCENT;
	uint256 public COMP_RESERVE = 30 * ONE_PERCENT;
	uint256 public TEAM_RESERVE = 9 * ONE_PERCENT;
	uint256 public BONUS_RESERVE = 1 * ONE_PERCENT;

	address public companyTokenHolder;
	address public teamTokenHolder;
	address public bonusTokenHolder;

	/* Freeze Account*/
	mapping(address => bool) public frozenAccount;
	event FrozenFunds(address target, bool frozen);

	using SafeMath for uint256;
	
	/*Private variables of the token*/
	function SCToken(address _companyAdd, address _teamAdd, address _bonusAdd) public{
		balances[_companyAdd] = balances[_companyAdd].add(COMP_RESERVE);
		totalSupply = totalSupply.add(COMP_RESERVE);
		Transfer(0x0, _companyAdd, COMP_RESERVE);
		companyTokenHolder = _companyAdd;

		balances[_teamAdd] = balances[_teamAdd].add(TEAM_RESERVE);
		totalSupply = totalSupply.add(TEAM_RESERVE);
		Transfer(0x0, _teamAdd, TEAM_RESERVE);
		teamTokenHolder = _teamAdd;

		balances[_bonusAdd] = balances[_bonusAdd].add(BONUS_RESERVE);
		totalSupply = totalSupply.add(BONUS_RESERVE);
		Transfer(0x0, _bonusAdd, BONUS_RESERVE);
		bonusTokenHolder = _bonusAdd;
	}

	function mint(address _investor, uint256 _value) onlyOwner whenNotPaused returns (bool success){
		require(_value > 0);
		require(_value + totalSupply < INITIAL_SUPPLY);
    	balances[_investor] = balances[_investor].add(_value);
		totalSupply = totalSupply.add(_value);
		Mint(_investor, _value);
		return true;
	}

	function freezeAccount(address target, bool freeze) onlyOwner {
		frozenAccount[target]=freeze;
		FrozenFunds(target,freeze);
	}

	function transfer(address _to, uint256 _value) returns (bool) {
		require(!frozenAccount[msg.sender]);
		return super.transfer(_to, _value);
		
	}
}