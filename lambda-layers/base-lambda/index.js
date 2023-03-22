const _ = require("lodash");

// Base lambda
exports.handler = async (event) => {
    const result = _.flattenDeep([1, [2, [3, [4]], 5]]);

    return {
        statusCode: 200,
        body: JSON.stringify(result)
    }
};
