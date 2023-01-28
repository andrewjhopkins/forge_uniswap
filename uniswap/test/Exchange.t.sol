// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Token.sol";
import "../src/Exchange.sol";

contract ExchangeTest is Test {
    Token public token;
    uint256 public initialSupply = 2000;
    address public tokenAddress;
    Exchange public exchange;

    fallback() external payable {}

    function setUp() public {
        token = new Token("Token", "TK", initialSupply);
        exchange = new Exchange(address(token));
    }

    function testConstructor() public {
        assertEq(exchange.tokenAddress(), address(token));
    }

    function testFailConstructor() public {
        new Exchange(address(0));
    }

    function testAddLiquidity() public {
        uint256 tokenAmount = 200;
        token.approve(address(exchange), tokenAmount);
        exchange.addLiquidity(tokenAmount);

        assertEq(token.balanceOf(address(this)), initialSupply - tokenAmount);
        assertEq(exchange.getReserve(), tokenAmount);
    }

    function testFailGetTokenAmount() public {
        exchange.getTokenAmount(0);
    }

    function testGetTokenAmount() public {
        token.approve(address(exchange), 2000);
        exchange.addLiquidity{value: 1000}(2000);
        assertEq(exchange.getReserve(), 2000);
        assertEq(address(exchange).balance, 1000);

        uint256 tokenAmount = exchange.getTokenAmount(1);
        assertEq(tokenAmount, 1);

        tokenAmount = exchange.getTokenAmount(100);
        assertEq(tokenAmount, 180);

        tokenAmount = exchange.getTokenAmount(1000);
        assertEq(tokenAmount, 994);
    }

    function testFailGetEthAmount() public {
        exchange.getEthAmount(0);
    }

    function testGetEthAmount() public {
        token.approve(address(exchange), 2000);
        exchange.addLiquidity{value: 1000}(2000);
        assertEq(exchange.getReserve(), 2000);
        assertEq(address(exchange).balance, 1000);

        uint256 tokenAmount = exchange.getEthAmount(2);
        assertEq(tokenAmount, 0);

        tokenAmount = exchange.getEthAmount(100);
        assertEq(tokenAmount, 47);

        tokenAmount = exchange.getEthAmount(2000);
        assertEq(tokenAmount, 497);
    }

    function testEthToTokenswap() public {
        token.approve(address(exchange), 2000);
        exchange.addLiquidity{value: 1000}(2000);
        assertEq(exchange.getReserve(), 2000);
        assertEq(address(exchange).balance, 1000);

        uint256 startEthBalance = address(this).balance;
        uint256 startTokenBalance = token.balanceOf(address(this));

        uint256 expected = exchange.getTokenAmount(2);

        exchange.ethToTokenSwap{value: 2}(expected);
        assertEq(startEthBalance - 2, address(this).balance);
        assertEq(startTokenBalance + expected, token.balanceOf(address(this)));
    }

    function testFailEthToTokenSwapDoesntMeetMin() public {
        token.approve(address(exchange), 2000);
        exchange.addLiquidity{value: 1000}(2000);
        assertEq(exchange.getReserve(), 2000);
        assertEq(address(exchange).balance, 1000);
        exchange.ethToTokenSwap{value: 2}(100);
    }

    function testEthToTokenSwapCanZeroSwap() public {
        token.approve(address(exchange), 2000);
        exchange.addLiquidity{value: 1000}(2000);
        assertEq(exchange.getReserve(), 2000);
        assertEq(address(exchange).balance, 1000);
        exchange.ethToTokenSwap{value: 0}(0);
    }

    function testTokenToEthSwap() public {
        token.approve(address(exchange), 1000);
        exchange.addLiquidity{value: 1000}(1000);
        assertEq(exchange.getReserve(), 1000);
        assertEq(address(exchange).balance, 1000);
        
        uint256 startEthBalance = address(this).balance;
        uint256 startTokenBalance = token.balanceOf(address(this));

        uint256 expected = exchange.getEthAmount(10);

        token.approve(address(exchange), 10);

        exchange.tokenToEthSwap(10, 1);
        assertEq(startEthBalance + expected, address(this).balance);
        assertEq(startTokenBalance - 10, token.balanceOf(address(this)));
    }

    function testFailTokenToEthSwapDoesntMeetMin() public {
        token.approve(address(exchange), 2000);
        exchange.addLiquidity{value: 1000}(2000);
        assertEq(exchange.getReserve(), 2000);
        assertEq(address(exchange).balance, 1000);
        exchange.tokenToEthSwap(1, 100);
    }

    function testTokenToEthSwapCanZeroSwap() public {
        token.approve(address(exchange), 2000);
        exchange.addLiquidity{value: 1000}(2000);
        assertEq(exchange.getReserve(), 2000);
        assertEq(address(exchange).balance, 1000);
        exchange.tokenToEthSwap(0, 0);
    }
}