const httpStatus = require('http-status');
const { NFT } = require('../models');
const ApiError = require('../utils/ApiError');

/**
 * Create a user
 * @param {Object} nftBody
 * @returns {Promise<User>}
 */
const createNft = async (nftBody) => {
  try {
  return NFT.create(nftBody);
  }
  catch (error) {
    throw new ApiError(error);
  }
};


/**
 * Get user by id
 * @param {ObjectId} id
 * @returns {Promise<User>}
 */
const getNftById = async (id) => {
  return NFT.findById(id);
};


module.exports = {
    createNft,
    getNftById,
};
