// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {OurToken} from "../src/OurToken.sol";

contract DeployOurToken is Script {
    uint256 public constant TOKEN_SUPPLY = 1000 ether;

    //Non abbiamo bisogno di un HelperConfig perchè il nostro token è identico in tutte le chain
    function run() external returns (OurToken) {
        //Faccio deploy
        vm.startBroadcast();
        //Crea istanza di Raffle passando i paramentri del costruttore
        OurToken ot = new OurToken(TOKEN_SUPPLY);
        vm.stopBroadcast();

        return (ot);
    }
}
