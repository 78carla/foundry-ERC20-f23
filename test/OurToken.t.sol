// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract OurTokenTest is StdCheats, Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public STARTING_BALANCE = 100 ether;

    function setUp() external {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        //Il deployer ha i token iniziali
        vm.prank(address(msg.sender));
        //Ne traferisce 100 a bob
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public {
        assertEq(STARTING_BALANCE, ourToken.balanceOf(bob));
    }

    function testAllowancesWorks() public {
        //TransferFrom  - devo approvare il trasferimento
        uint256 initialAllowance = 1000;
        uint256 transferAmount = 500;

        //Bob approves Alice to spend toekns on his behalf
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);
        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testInitialSupply() public {
        assertEq(ourToken.totalSupply(), deployer.TOKEN_SUPPLY());
    }

    function testTransfers() public {
        address recipient = address(0x123);
        uint256 amount = 1000;
        vm.prank(msg.sender);
        ourToken.transfer(recipient, amount);
        assertEq(ourToken.balanceOf(recipient), amount);
    }

    function testBalanceUpdatesAfterTransfers() public {
        address recipient = address(0x123);
        uint256 initialBalance = ourToken.balanceOf(msg.sender);
        uint256 amount = 1000;
        vm.prank(msg.sender);
        ourToken.transfer(recipient, amount);
        assertEq(ourToken.balanceOf(msg.sender), initialBalance - amount);
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(ourToken)).mint(address(this), 1);
    }

    function testAllowance() public {
        address spender = address(0xabc); // Replace with the spender's address
        uint256 allowanceAmount = 200;

        ourToken.approve(spender, allowanceAmount);

        assertEq(ourToken.allowance(address(this), spender), allowanceAmount);
    }

    function testDecreaseAllowance() public {
        address spender = address(0xdef); // Replace with the spender's address
        uint256 initialAllowance = 200;
        uint256 decreaseAmount = 50;

        ourToken.approve(spender, initialAllowance);

        // Decrease the allowance
        ourToken.decreaseAllowance(spender, decreaseAmount);

        assertEq(
            ourToken.allowance(address(this), spender),
            initialAllowance - decreaseAmount
        );
    }

    function testIncreaseAllowance() public {
        address spender = address(0xdef); // Replace with the spender's address
        uint256 initialAllowance = 200;
        uint256 increaseAmount = 50;

        ourToken.approve(spender, initialAllowance);

        // Increase the allowance
        ourToken.increaseAllowance(spender, increaseAmount);

        assertEq(
            ourToken.allowance(address(this), spender),
            initialAllowance + increaseAmount
        );
    }
}
