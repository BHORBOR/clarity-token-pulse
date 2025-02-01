# TokenPulse

A decentralized analytics tool built on Stacks blockchain for tracking token metrics and statistics. TokenPulse provides real-time insights into token transfers, holder distribution, and advanced market metrics.

## Features

- Track total number of token transfers
- Monitor unique token holders
- Record largest transfers
- Track holder distribution statistics
- Historical analytics data
- Price tracking and history
- Advanced token metrics:
  - Token velocity
  - Concentration index
  - Turnover ratio
- Enhanced holder analytics
- Price-based metrics and statistics

## Contract Interface

The contract provides read-only functions to query analytics data and public functions to register token transfers and update metrics.

### New Features

- **Price Tracking**: Track current price, all-time high, and all-time low
- **Advanced Metrics**: Calculate token velocity, concentration index, and turnover ratio
- **Enhanced Statistics**: Track average transfer size and holder activity metrics
- **Price-Based Analytics**: Analyze token metrics in relation to current price

## Usage

Interact with the contract by calling the public functions to record transfers and query the analytics data using read-only functions.

### Price Updates
```clarity
(contract-call? .token-pulse update-price-data token-id price)
```

### Metrics Query
```clarity
(contract-call? .token-pulse get-token-metrics token-id)
```
