const mongoose = require('mongoose');
const { toJSON } = require('./plugins');

const nftSchema = mongoose.Schema(
  {
    owner: {
      type: String,
      required: true
    },
    tokenId: {
        type: String,
        required: true
      },
    metadata: {
        type: String,
        required: true
    }
  },
  {
    timestamps: true,
  }
);

// add plugin that converts mongoose to json
nftSchema.plugin(toJSON);

/**
 * @typedef NFT
 */
const NFT = mongoose.model('NFT', nftSchema);

module.exports = NFT;
