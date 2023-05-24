//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DesignatedShareNFT is ERC721 {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    event TransferShare(address indexed from, address indexed to, uint256 _tokenId, uint256 amount);

    struct Share {
        address owner;
        uint256 amount;
    }

    struct InitialOwner {
        address owner;
        uint256 amount;
    }

    struct Vote {
        address voter;
        uint256 number;
    }

    mapping(uint256 => Vote[]) public voteInfo;
    mapping(address => uint256[]) public ownerToTokenIds;
    mapping(uint256 => Share[]) public tokenIdToShares;
    mapping(uint256 => InitialOwner) public initialOwners;
    constructor() ERC721("Love Key Exchange", "LKE") {}

    function mint(address _owner, uint256 _amount) external {
        _tokenIds.increment();

        uint256 tokenId = _tokenIds.current();

        InitialOwner memory initialOwner = InitialOwner({
            owner : _owner,
            amount : _amount
            });
        initialOwners[tokenId] = initialOwner;

        Share memory newShare = Share({
            owner : _owner,
            amount : _amount
            });
        tokenIdToShares[tokenId].push(newShare);
        ownerToTokenIds[_owner].push(tokenId);

        _safeMint(_owner, tokenId);
    }

    function transferShare(address _from, uint256 _tokenId, address _to, uint256 _amount) external {
        require(existTokenId(ownerToTokenIds[_from], _tokenId), "You are not the owner of tokenId");
        require(getTokenIdCount(_tokenId, _from, _amount), "You not have enough amount to transfer");


        if (getShareExit(_tokenId, _to)) {
            Share memory share = getShareEntity(_tokenId, _to);
            share.amount += _amount;

            uint256 shareIndex = getShareArrayIndex(_tokenId, _to);
            tokenIdToShares[_tokenId][shareIndex] = share;
        } else {
            Share memory newShare = Share({
                owner : _to,
                amount : _amount
                });
            tokenIdToShares[_tokenId].push(newShare);
            ownerToTokenIds[_to].push(_tokenId);
        }

        Share memory share = getShareEntity(_tokenId, _from);
        share.amount = share.amount - _amount;

        uint256 shareOneIndex = getShareArrayIndex(_tokenId, _from);
        tokenIdToShares[_tokenId][shareOneIndex] = share;
        transfer(_from, _to, _tokenId, _amount);
    }

    function transfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 amount
    ) internal virtual {
        require(to != address(0), "ERC721: transfer to the zero address");
        emit TransferShare(from, to, tokenId, amount);
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

    function getShareEntity(uint256 _tokenId, address owner) internal view returns (Share memory){
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

    function getShareIndex(uint256 _tokenId, address owner) internal view returns (uint256){
        uint256 index;
        Share[] memory shareList = tokenIdToShares[_tokenId];
        for (uint i = 0; i < shareList.length; i++) {
            if (shareList[i].owner == owner) {
                index = i;
                return index;
            }
        }
        return index;
    }

    function getShareArrayIndex(uint256 _tokenId, address owner) internal view returns (uint256){
        uint256 index;
        Share[] memory shareList = tokenIdToShares[_tokenId];
        for (uint i = 0; i < shareList.length; i++) {
            if (shareList[i].owner == owner) {
                index = i;
                return index;
            }
        }
        return index;
    }


    function getTokenIdsByAddress(address owner) public view returns (uint256[] memory){
        return (ownerToTokenIds[owner]);
    }

    function getAddressByTokenId(uint256 _tokenId) public view returns (Share[] memory){
        return (tokenIdToShares[_tokenId]);
    }

    function voteInfoAdd(address _from, uint256 _tokenId, address _voter, uint256 _number) public {
        Vote memory newVote = Vote({
            voter : _voter,
            number : _number
            });
        voteInfo[_tokenId].push(newVote);
        transferShare(_from, _tokenId, _voter, _number);
    }


    function getVoteProportion(uint256 _tokenId) public view returns (uint256, uint256){
        uint256 all = initialOwners[_tokenId].amount;
        uint256 realVoteNumber = 0;
        Vote[] memory voteList = voteInfo[_tokenId];
        for (uint i = 0; i < voteList.length; i++) {
            realVoteNumber += voteList[i].number;
        }

        return (all, realVoteNumber);
    }

    function processAcquisitionResult(address acquirer, uint256 _tokenId){
        _owners[_tokenId] = acquirer;
        delete voteInfo[_tokenId];
    }


}
