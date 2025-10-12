# Usage Examples

## Basic Example
```javascript
const example = new ExampleClass({
  option1: 'value1',
  option2: 'value2'
});

example.process();
```

## Advanced Example
```javascript
const advancedExample = new AdvancedExample({
  configuration: {
    timeout: 5000,
    retries: 3
  }
});

await advancedExample.execute();
```

## Error Handling
```javascript
try {
  const result = await example.process();
  console.log('Success:', result);
} catch (error) {
  console.error('Error:', error.message);
}
```
