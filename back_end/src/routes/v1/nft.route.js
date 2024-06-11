const express = require('express');
const nftController = require('../../controllers/nft.controller');

const router = express.Router();

router
  .route('/')
  .post(nftController.createNft);

router
  .route('/:nftId')
  .get(nftController.getNft);

module.exports = router;
