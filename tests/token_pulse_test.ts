import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Test token transfer registration and stats tracking",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const wallet1 = accounts.get('wallet_1')!;
        const wallet2 = accounts.get('wallet_2')!;
        
        // Register a transfer
        let block = chain.mineBlock([
            Tx.contractCall('token_pulse', 'register-transfer', [
                types.principal(deployer.address),
                types.principal(wallet1.address),
                types.principal(wallet2.address),
                types.uint(1000)
            ], deployer.address)
        ]);
        
        block.receipts[0].result.expectOk().expectBool(true);
        
        // Check token stats
        let statsBlock = chain.mineBlock([
            Tx.contractCall('token_pulse', 'get-token-stats', [
                types.principal(deployer.address)
            ], deployer.address)
        ]);
        
        const stats = statsBlock.receipts[0].result.expectOk().expectSome();
        assertEquals(stats['total-transfers'], types.uint(1));
        assertEquals(stats['total-volume'], types.uint(1000));
        assertEquals(stats['largest-transfer'], types.uint(1000));
    }
});

Clarinet.test({
    name: "Test holder balance tracking",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const wallet1 = accounts.get('wallet_1')!;
        const wallet2 = accounts.get('wallet_2')!;
        
        // Register transfers
        let block = chain.mineBlock([
            Tx.contractCall('token_pulse', 'register-transfer', [
                types.principal(deployer.address),
                types.principal(wallet1.address),
                types.principal(wallet2.address),
                types.uint(500)
            ], deployer.address)
        ]);
        
        // Check holder balances
        let balanceBlock = chain.mineBlock([
            Tx.contractCall('token_pulse', 'get-holder-balance', [
                types.principal(deployer.address),
                types.principal(wallet2.address)
            ], deployer.address)
        ]);
        
        const balance = balanceBlock.receipts[0].result.expectOk().expectSome();
        assertEquals(balance['balance'], types.uint(500));
    }
});

Clarinet.test({
    name: "Test historical data recording",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const wallet1 = accounts.get('wallet_1')!;
        const wallet2 = accounts.get('wallet_2')!;
        
        // Register transfer
        let block = chain.mineBlock([
            Tx.contractCall('token_pulse', 'register-transfer', [
                types.principal(deployer.address),
                types.principal(wallet1.address),
                types.principal(wallet2.address),
                types.uint(1000)
            ], deployer.address)
        ]);
        
        // Check historical data
        let historicalBlock = chain.mineBlock([
            Tx.contractCall('token_pulse', 'get-historical-data', [
                types.principal(deployer.address),
                types.uint(block.height)
            ], deployer.address)
        ]);
        
        const historicalData = historicalBlock.receipts[0].result.expectOk().expectSome();
        assertEquals(historicalData['daily-volume'], types.uint(1000));
        assertEquals(historicalData['active-holders'], types.uint(1));
    }
});