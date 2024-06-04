// SPDX-Licence-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol"; // Test contract
import {BoxV1} from "../src/BoxV1.sol"; // BoxV1 contract
import {BoxV2} from "../src/BoxV2.sol"; // BoxV2 contract
import {DeployBox} from "../script/DeployBox.s.sol"; // DeployBox contract
import {Upgradable} from "../script/Upgradable.s.sol"; // Upgradable contract

contract DeployAndUpgradeTest is Test {
    DeployBox public deployBoxV1;
    Upgradable public upgradable;
    BoxV2 public boxV2;

    address owner = makeAddr("owner");
    address proxy;

    function setUp() external {
        deployBoxV1 = new DeployBox();
        upgradable = new Upgradable();
        boxV2 = new BoxV2();

        proxy = deployBoxV1.run();
    }

    function testProxyStratsAsBoxV1() external {
        vm.expectRevert();
        BoxV2(proxy).setNumber(7);
    }

    function test_CanUpgrade() external {
        uint256 intialVersion = BoxV1(proxy).version();
        console.log("Initial Version of Box: ", intialVersion);
        // Upgrade to BoxV2
        BoxV1(proxy).upgradeToAndCall(address(boxV2), "");

        uint256 newVersion = BoxV1(proxy).version();
        console.log("New Version of Box: ", newVersion);

        // NB assertEq is compares two first two arguments  and the 3rd argument is the error message and its always a string
        assertEq(intialVersion, 1, "Initial version should be one");
        assertEq(newVersion, 2, "Version should be two");
    }
}
