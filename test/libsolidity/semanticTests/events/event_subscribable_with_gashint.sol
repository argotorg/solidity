contract Test {
    event subscribable PriceUpdated(uint256 price) gasHint(50000);

    function updatePrice(uint256 _price) public {
        emit PriceUpdated(_price);
    }
}
// ----
// updatePrice(uint256): 1000 ->
// ~ emit PriceUpdated(uint256): 0x03e8
