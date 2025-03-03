import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v0.14.0/index.ts';

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

Clarinet.test({
    name: "Test price update with TWAP calculation",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const token = deployer.address;
        
        // Initialize contract
        let block = chain.mineBlock([
            Tx.contractCall('token_pulse', 'initialize', [], deployer.address)
        ]);
        
        // Update price
        let block2 = chain.mineBlock([
            Tx.contractCall('token_pulse', 'update-price-data', 
                [types.principal(token), types.uint(1000000)], 
                deployer.address)
        ]);
        
        block2.receipts[0].result.expectOk().expectBool(true);
        
        // Test invalid price
        let block3 = chain.mineBlock([
            Tx.contractCall('token_pulse', 'update-price-data',
                [types.principal(token), types.uint(0)],
                deployer.address)
        ]);
        
        block3.receipts[0].result.expectErr(107);
    }
});
