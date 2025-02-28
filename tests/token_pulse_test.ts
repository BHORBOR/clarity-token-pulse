// [Previous imports remain unchanged]

Clarinet.test({
    name: "Ensure proper contract initialization",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        
        // Test initialization
        let block = chain.mineBlock([
            Tx.contractCall('token_pulse', 'initialize', [], deployer.address)
        ]);
        
        block.receipts[0].result.expectOk().expectBool(true);
        
        // Test double initialization fails
        let block2 = chain.mineBlock([
            Tx.contractCall('token_pulse', 'initialize', [], deployer.address)
        ]);
        
        block2.receipts[0].result.expectErr(104);
    }
});

// [Previous tests remain unchanged with added initialization calls]
