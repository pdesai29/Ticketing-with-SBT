// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SoulboundToken is ERC721, Ownable, ERC721Holder {
    uint256 private _totalSupply;
    mapping(uint256 => string) private _tokenURIs;
    mapping(address => bool) private _hasMintedSBT;

    struct UserData {
        string profileURI;
        address sbtAddress;
    }

    mapping(address => UserData) private _userMap;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function getTotalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function mintSBT(string memory sbtTokenURI, string memory profileURI) external returns (uint256) {
        require(!_hasMintedSBT[msg.sender], "You have already minted an SBT");

        uint256 tokenId = _totalSupply;
        _safeMint(msg.sender, tokenId);
        _setSBTTokenURI(tokenId, sbtTokenURI);

        _userMap[msg.sender] = UserData(profileURI, address(this));
        _hasMintedSBT[msg.sender] = true;

        _totalSupply++; // Increment total supply

        return tokenId;
    }

    function getUserProfile(address user) external view returns (string memory) {
        return _userMap[user].profileURI;
    }

    function getSBTAddress(address user) external view returns (address) {
        return _userMap[user].sbtAddress;
    }

    function _setSBTTokenURI(uint256 tokenId, string memory sbtTokenURI) internal virtual {
        _tokenURIs[tokenId] = sbtTokenURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = super.tokenURI(tokenId);
        if (bytes(baseURI).length == 0) {
            return "";
        }
        return string(abi.encodePacked(baseURI, _tokenURIs[tokenId]));
    }

    function isSBTTransferable() public pure returns (bool) {
        return false; // SBT is non-transferable
    }

    // Override transfer functions to prevent transfers
    function transferFrom(
        address /* from */,
        address /* to */,
        uint256 /* tokenId */
    ) public pure override {
        revert("SBT: Transfers are not allowed");
    }

    function safeTransferFrom(
        address /* from */,
        address /* to */,
        uint256 /* tokenId */
    ) public pure override {
        revert("SBT: Transfers are not allowed");
    }

    function safeTransferFrom(
        address /* from */,
        address /* to */,
        uint256 /* tokenId */,
        bytes memory /* _data */
    ) public pure override {
        revert("SBT: Transfers are not allowed");
    }

    // Override OpenZeppelin's transfer functions
    function _transfer(
        address /* from */,
        address /* to */,
        uint256 /* tokenId */
    ) internal pure override {
        revert("SBT: Transfers are not allowed");
    }


    // Burn function to destroy the SBT token
    function burn(uint256 tokenId) external {
        require(_exists(tokenId), "SBT: Token does not exist");
        require(ownerOf(tokenId) == msg.sender, "SBT: Only the owner can burn the token");

        _burn(tokenId);

        delete _tokenURIs[tokenId];
        delete _hasMintedSBT[msg.sender];
    }
}
