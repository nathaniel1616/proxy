// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
// import BoxV2 and BoxV1
import {BoxV2} from "../src/BoxV2.sol";
import {BoxV1} from "../src/BoxV1.sol";

contract Upgradable is Script {
    function run() external returns (address) {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("ERC1967Proxy", block.chainid);
        vm.startBroadcast();
        BoxV2 newBox = new BoxV2();
        address proxy = upgradeBox(mostRecentlyDeployed, address(newBox));
        vm.stopBroadcast();
        return proxy;
    }

    function upgradeBox(address proxyAddress, address newBox) public returns (address) {
        vm.startBroadcast();
        BoxV1 proxy = BoxV1(proxyAddress);

        proxy.upgradeToAndCall(address(newBox), ""); //proxy contract will be upgraded to newBox
        vm.stopBroadcast();
        return address(proxy);
    }
}
