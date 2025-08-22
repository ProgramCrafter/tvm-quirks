@pure
fun tuple.changeTuple<X>(mutate self, pos: int, value: X): self
    asm(self value pos) "SETINDEXVAR";

@pure
fun getC7(): tuple
    asm "c7 PUSHCTR"

fun vmInvokeGetAddress(owner_address: address, c7: tuple, master_data: cell, master_code: cell): address
    asm "CTOS            // owner_addr c7 md mc"
        "2 PUSHINT       // owner_addr c7 md mc args"
        "103289 PUSHINT  // owner_addr c7 md mc args get_jwa_method_id"
        "5 0 REVERSE     // owner_addr get_jwa_method_id args mc md c7"
        "53 RUNVM        // address exit_code c4' c5'"
        "3 BLKDROP       // address";

@inline_ref
fun getJettonWalletAddress(owner_address: address, code: cell, data: cell, master_addr: address): address {
    var c7 = getC7();

    var first_c7: tuple = c7.first();

    c7 = c7.changeTuple(
        0,
        first_c7.changeTuple(8, master_addr).changeTuple(10, code)
    );
    return vmInvokeGetAddress(owner_address, c7, data, code);
}

@inline
fun calcMyJettonWallet(master_addr: address, code: cell, data: cell): address {
    return getJettonWalletAddress(contract.getAddress(), code, data, master_addr);
}