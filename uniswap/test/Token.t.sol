// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Token.sol";

contract TokeneTest is Test {
    Token public token;

    string public tokenName = "Token";
    string public tokenSymbol = "TK";
    uint256 public tokenSupply = 200;

    function setUp() public {
        token = new Token(tokenName, tokenSymbol, tokenSupply);
    }

    function testConstructor() public {
        assertEq(token.name(), tokenName);
        assertEq(token.symbol(), tokenSymbol);
        assertEq(token.totalSupply(), tokenSupply);
        assertEq(token.balanceOf(address(this)), tokenSupply);
    }
}