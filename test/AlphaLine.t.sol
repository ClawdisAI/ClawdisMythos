// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {AleaStrategies}     from "../contracts/AleaStrategies.sol";
import {MockERC20}     from "./mocks/MockERC20.sol";

contract AleaStrategiesTest is Test {
    AleaStrategies public aleastategies;
    MockERC20 public usdc;

    address public owner    = address(this);
    address public reporter = address(0xA11CE);
    address public treasury = address(0x7E5);

    bytes32 constant MARKET_ID = keccak256("nyk-okc-finals-g5");

    function setUp() public {
        usdc       = new MockERC20("USD Coin", "USDC", 6);
        aleastategies  = new AleaStrategies(usdc, treasury);
    }

    // ─────────────────────────────── createMarket ─────────────────────────

    function test_createMarket() public {
        aleastategies.createMarket(
            MARKET_ID,
            AleaStrategies.Sport.NBA,
            "Knicks @ Thunder - Finals G5",
            "Will Thunder win the championship?"
        );

        AleaStrategies.Market memory m = aleastategies.getMarket(MARKET_ID);
        assertEq(m.id, MARKET_ID);
        assertEq(uint8(m.sport), uint8(AleaStrategies.Sport.NBA));
        assertEq(uint8(m.status), uint8(AleaStrategies.MarketStatus.Live));
        assertEq(aleastategies.marketCount(), 1);
    }

    function test_createMarket_onlyOwner() public {
        vm.prank(reporter);
        vm.expectRevert(AleaStrategies.Unauthorized.selector);
        aleastategies.createMarket(MARKET_ID, AleaStrategies.Sport.NBA, "game", "pick");
    }

    // ─────────────────────────────── fileSignal ───────────────────────────

    function test_fileSignal_emitsEdgeAlert() public {
        _createMarket();

        vm.expectEmit(true, false, false, true);
        emit AleaStrategies.EdgeAlertFired(MARKET_ID, 900, reporter);

        vm.prank(reporter);
        aleastategies.fileSignal(
            MARKET_ID,
            AleaStrategies.SignalType.Injury,
            7_600, // marketProb 76%
            8_500  // alphaProb  85% → edge 900bps
        );
    }

    function test_fileSignal_belowMinEdge_reverts() public {
        _createMarket();
        vm.prank(reporter);
        vm.expectRevert();
        aleastategies.fileSignal(
            MARKET_ID,
            AleaStrategies.SignalType.Sharp,
            5_000, // marketProb 50%
            5_100  // alphaProb  51% → edge 100bps < 300bps min
        );
    }

    function test_fileSignal_invalidProb_reverts() public {
        _createMarket();
        vm.prank(reporter);
        vm.expectRevert(AleaStrategies.InvalidProbability.selector);
        aleastategies.fileSignal(MARKET_ID, AleaStrategies.SignalType.Lineup, 10_001, 5_000);
    }

    function test_edge_returnsLatestSignalEdge() public {
        _createMarket();
        vm.prank(reporter);
        aleastategies.fileSignal(MARKET_ID, AleaStrategies.SignalType.Rest, 6_300, 7_200);

        uint256 e = aleastategies.edge(MARKET_ID);
        assertEq(e, 900); // 7200 - 6300
    }

    // ─────────────────────────────── settleMarket ─────────────────────────

    function test_settleMarket_won() public {
        _createMarket();
        aleastategies.settleMarket(MARKET_ID, true);

        AleaStrategies.Market memory m = aleastategies.getMarket(MARKET_ID);
        assertEq(uint8(m.status), uint8(AleaStrategies.MarketStatus.Settled));
        assertTrue(m.result);
        assertGt(m.settledAt, 0);
    }

    function test_settleMarket_alreadySettled_reverts() public {
        _createMarket();
        aleastategies.settleMarket(MARKET_ID, true);
        vm.expectRevert(AleaStrategies.MarketAlreadySettled.selector);
        aleastategies.settleMarket(MARKET_ID, false);
    }

    function test_settleMarket_onlyOwner() public {
        _createMarket();
        vm.prank(reporter);
        vm.expectRevert(AleaStrategies.Unauthorized.selector);
        aleastategies.settleMarket(MARKET_ID, true);
    }

    // ─────────────────────────────── ownership ────────────────────────────

    function test_transferOwnership() public {
        aleastategies.transferOwnership(reporter);
        assertEq(aleastategies.owner(), reporter);
    }

    // ─────────────────────────────── helpers ──────────────────────────────

    function _createMarket() internal {
        aleastategies.createMarket(
            MARKET_ID,
            AleaStrategies.Sport.NBA,
            "Knicks @ Thunder - Finals G5",
            "Will Thunder win the championship?"
        );
    }
}
