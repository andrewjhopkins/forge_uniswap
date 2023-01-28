// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Token.sol";
import "../src/Factory.sol";
import "../src/Exchange.sol";

contract FactoryTest is Test {
    Token public token;
    Exchange public exchange;
    Factory public factory;

    address public tokenExchangeAddress;

    string public tokenName = "Token";
    string public tokenSymbol = "TK";
    uint256 public tokenSupply = 200;

    function setUp() public {
        factory = new Factory();
        token = new Token(tokenName, tokenSymbol, tokenSupply);
        tokenExchangeAddress = factory.createExchange(address(token));
    }

    function testExchangeCreated() public {
        assertEq(factory.getExchange(address(token)), tokenExchangeAddress);
    }

    function testFailToCreateExchangeIfZeroAddress() public {
        factory.createExchange(address(0));
    }

    function testFailToCreateExchangeIfAlreadyExists() public {
        factory.createExchange(address(token));
    }
}