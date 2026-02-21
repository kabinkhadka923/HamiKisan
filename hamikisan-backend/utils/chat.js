const buildRoomId = (userA, userB) => {
  const [first, second] = [Number(userA), Number(userB)].sort((a, b) => a - b);
  return `dm_${first}_${second}`;
};

module.exports = {
  buildRoomId,
};
