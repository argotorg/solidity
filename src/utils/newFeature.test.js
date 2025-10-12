const DataProcessor = require('./newFeature');

describe('DataProcessor', () => {
  let processor;

  beforeEach(() => {
    processor = new DataProcessor({
      timeout: 1000,
      retries: 1
    });
  });

  test('should process data correctly', async () => {
    const inputData = [
      { id: 1, name: 'Test 1' },
      { id: 2, name: 'Test 2' }
    ];

    const result = await processor.process(inputData);
    
    expect(result).toHaveLength(2);
    expect(result[0]).toHaveProperty('processed', true);
    expect(result[0]).toHaveProperty('timestamp');
  });

  test('should handle empty data', async () => {
    const result = await processor.process([]);
    expect(result).toEqual([]);
  });

  test('should handle errors gracefully', async () => {
    const invalidData = null;
    
    await expect(processor.process(invalidData))
      .rejects
      .toThrow('Failed to process data');
  });
});
