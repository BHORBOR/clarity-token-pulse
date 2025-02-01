import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Test token transfer registration and enhanced stats tracking",
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
        
        // Update price data
        let priceBlock = chain.mineBlock([
            Tx.contractCall('token_pulse', 'update-price-data', [
                types.principal(deployer.address),
                types.uint(100)
            ], deployer.address)
        ]);
        
        priceBlock.receipts[0].result.expectOk().expectBool(true);
        
        // Check token stats with price data
        let statsBlock = chain.mineBlock([
            Tx.contractCall('token_pulse', 'get-token-stats', [
                types.principal(deployer.address)
            ], deployer.address)
        ]);
        
        const stats = statsBlock.receipts[0].result.expectOk().expectSome();
        assertEquals(stats['total-transfers'], types.uint(1));
        assertEquals(stats['total-volume'], types.uint(1000));
        assertEquals(stats['average-transfer'], types.uint(1000));
        assertEquals(stats['price-data']['current-price'], types.uint(100));
    }
});

Clarinet.test({
    name: "Test token metrics calculation",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const wallet1 = accounts.get('wallet_1')!;
        const wallet2 = accounts.get('wallet_2')!;
        
        // Setup initial state
        let block = chain.mineBlock([
            Tx.contractCall('token_pulse', 'register-transfer', [
                types.principal(deployer.address),
                types.principal(wallet1.address),
                types.principal(wallet2.address),
                types.uint(1000)
            ], deployer.address),
            Tx.contractCall('token_pulse', 'update-price-data', [
                types.principal(deployer.address),
                types.uint(100)
            ], deployer.address)
        ]);
        
        // Check metrics
        let metricsBlock = chain.mineBlock([
            Tx.contractCall('token_pulse', 'get-token-metrics', [
                types.principal(deployer.address)
            ], deployer.address)
        ]);
        
        const metrics = metricsBlock.receipts[0].result.expectOk().expectSome();
        assertEquals(metrics['velocity'], types.uint(1000));
        assertEquals(metrics['turnover-ratio'], types.uint(10));
    }
});
