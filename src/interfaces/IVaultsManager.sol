// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

interface IVaultsManager {
  error AlreadyVotedFor();
  error AlreadyVotedAgainst();
  error NotOwner();
  error TooManyForVotes();
  error TooManyAgainstVotes();

  event Voted(uint indexed id, address indexed vault, bool vote);

  /**
   * @dev Allows an dNFT owner to vote for the specified NFT by incrementing 
   *      the vote count for a designated vault. 
   * @param id The ID of the NFT for which to vote.
   * @param vault The address of the designated vault to receive the vote.
   * Requirements:
   * - The caller must be the owner of the NFT with the specified ID.
   * - The caller must not have already voted for the specified NFT.
   * Emits a {Voted} event indicating that the vote has been cast.
   */
  function voteFor(uint id, address vault) external;

  /**
   * @dev Allows an NFT owner to vote against the specified NFT by decrementing
          the vote count for a designated vault. 
   * @param id The ID of the NFT for which to vote.
   * @param vault The address of the designated vault to receive the vote.
   * Requirements:
   * - The caller must be the owner of the NFT with the specified ID.
   * - The caller must have already voted for the specified NFT.
   * Emits a {Voted} event indicating that the vote has been cast.
   */
  function voteAgainst(uint id, address vault) external;
}
