pragma solidity ^0.4.4;

library ConvertLib{
	function convert(uint amount, uint conversionRate) constant returns (uint) {
		return amount * conversionRate;
	}
}
