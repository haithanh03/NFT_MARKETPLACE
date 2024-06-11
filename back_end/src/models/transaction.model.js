const mongoose = require('mongoose');

const transactionSchema = mongoose.Schema(
  {
    transaction_hash: {
      type: String,
      required: true,
      trim: true,
    },
    block_hash: {
      type: String,
      required: true,
      trim: true,
    },
    block_number: {
      type: Number,
      required: true,
    },
    event_name: {
      type: String,
      required: true,
      trim: true,
    },
    sender_address: {
      type: String,
      required: true,
      trim: true,
    },
    receiver_address: {
      type: String,
      required: true,
      trim: true
    }
  },
  {
    timestamps: true,
  }
);


/**
 * @typedef Transaction
 */
const Transaction = mongoose.model('Transaction', transactionSchema);

module.exports = Transaction;
