const httpStatus = require('http-status');
const ApiError = require('../utils/ApiError');
const catchAsync = require('../utils/catchAsync');
const { nftService } = require('../services');

const createNft = catchAsync(async (req, res) => {
  const nft = await nftService.createNft(req.body);
  res.status(httpStatus.CREATED).send(nft);
});


const getNft = catchAsync(async (req, res) => {
  const nft = await nftService.getNftById(req.params.nftId);
  if (!nft) {
    throw new ApiError(httpStatus.NOT_FOUND, 'User not found');
  }
  res.send(nft);
});

module.exports = {
    createNft,
    getNft,
};
