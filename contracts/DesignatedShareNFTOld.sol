//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DesignatedShareOldNFT is ERC721 {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Share {
        address owner;
        uint256 amount;
    }

    Share[] public shares;
    mapping(address => uint256[]) public ownerToTokenIds;
    mapping(uint256 => Share[]) public tokenIdToShares;

    constructor() ERC721("Love Key Exchange", "LKE") {}

    function mint(address _owner, uint256 _amount) external {
        _tokenIds.increment();

        uint256 tokenId = _tokenIds.current();
        Share memory newShare = Share({
            owner : _owner,
            amount : _amount
            });
        shares.push(newShare);

        tokenIdToShares[tokenId] = shares;
        ownerToTokenIds[_owner].push(tokenId);

        _safeMint(_owner, tokenId);
    }

    function transferShare(address _from, uint256 _tokenId, address _to, uint256 _amount) external {
        require(existTokenId(ownerToTokenIds[_from], _tokenId), "You are not the owner of tokenId");
        require(getTokenIdCount(_tokenId, _from, _amount), "You not have enough amount to transfer");

        ownerToTokenIds[_to].push(_tokenId);
        if (getShareExit(_tokenId, _to)) {
            Share memory share = getShareEntity(_tokenId, _to);
            share.amount = _amount + share.amount;
        } else {
            Share memory newShare = Share({
                owner : _to,
                amount : _amount
                });
            shares.push(newShare);
            tokenIdToShares[_tokenId] = shares;
        }

        Share memory share = getShareEntity(_tokenId, _from);
        share.amount = share.amount - _amount;

        _transfer(_from, _to, _tokenId);
    }

    function existTokenId(uint256[] memory _tokenIds, uint256 _tokenId) internal pure returns (bool) {
        for (uint i = 0; i < _tokenIds.length; i++) {
            if (_tokenIds[i] == _tokenId) {
                return true;
            }
        }
        return false;
    }

    function getTokenIdCount(uint256 _tokenId, address owner, uint256 _amount) internal view returns (bool){
        Share[] memory shares = tokenIdToShares[_tokenId];
        for (uint i = 0; i < shares.length; i++) {
            if (shares[i].owner == owner) {
                if (shares[i].amount >= _amount) {
                    return true;
                } else {
                    return false;
                }
            }
        }
        return false;
    }

    function getShareExit(uint256 _tokenId, address owner) internal view returns (bool){
        Share[] memory shares = tokenIdToShares[_tokenId];
        for (uint i = 0; i < shares.length; i++) {
            if (shares[i].owner == owner) {
                return true;
            }
        }
        return false;
    }

    function getShareEntity(uint256 _tokenId, address owner) internal  view returns (Share memory){
        Share  memory share;
        Share[] memory shareList = tokenIdToShares[_tokenId];
        for (uint i = 0; i < shareList.length; i++) {
            if (shareList[i].owner == owner) {
                share = shareList[i];
                return share;
            }
        }
        return share;
    }

}
