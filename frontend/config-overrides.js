/* config-overrides.js */

module.exports = function override(config, env) {
  // Ignore source map warnings
  if (!config.ignoreWarnings) {
    config.ignoreWarnings = [];
  }
  
  // Add specific pattern for react-datepicker source map warnings
  config.ignoreWarnings.push(/Failed to parse source map/);
  
  return config;
};