// SPDX-License-Identifier: MIT

// File: contracts/StringUtil.sol


pragma solidity ^0.8.9;

library StringUtil {
        function containsSpecialCharacter(string memory _str, string memory _specialCharacter) internal pure returns (bool) {
            bytes memory strBytes = bytes(_str);
            bytes memory charBytes = bytes(_specialCharacter);

            for (uint256 i = 0; i < strBytes.length; i++) {
                if (strBytes[i] == charBytes[0]) {
                    return true;
                }
            }
            return false;
        }

        function uint2str(uint256 value) internal pure returns (string memory) {
            if (value == 0) {
                return "0";
            }
            uint256 temp = value;
            uint256 digits;
            while (temp != 0) {
                digits++;
                temp /= 10;
            }
            bytes memory buffer = new bytes(digits);
            while (value != 0) {
                digits -= 1;
                buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
                value /= 10;
            }
            return string(buffer);
        }

         // Function to check if a string contains a specific special character
        function containsSpecialCharacters(string memory _str, string memory _specialCharacter) internal pure returns (bool) {
            bytes memory strBytes = bytes(_str);
            bytes memory charBytes = bytes(_specialCharacter);

            for (uint256 i = 0; i < strBytes.length; i++) {
                if (strBytes[i] == charBytes[0]) {
                    return true;
                }
            }
            return false;
        }

        function hasConsecutiveHyphens(string memory handleName) internal pure returns (bool) {
            bytes memory handleBytes = bytes(handleName);
            bytes1 hyphenByte = "-";
            
            for (uint256 i = 1; i < handleBytes.length; i++) {
                if (handleBytes[i] == hyphenByte && handleBytes[i - 1] == hyphenByte) {
                    return true;
                }
            }
            
            return false;
        }

        function hasValidPrefix(string memory handleName) internal pure returns (bool) {
            bytes memory handleBytes = bytes(handleName);
            bytes memory xnPrefixBytes = bytes("xn--");

            if (handleBytes.length >= xnPrefixBytes.length) {
                for (uint256 i = 0; i < xnPrefixBytes.length; i++) {
                    if (handleBytes[i] != xnPrefixBytes[i]) {
                        return false;
                    }
                }
                return true;
            }

            return false;
        }

        function countDots(string memory handleName) internal pure returns (uint256) {
            bytes memory handleBytes = bytes(handleName);
            uint256 dotCount = 0;
            for (uint256 i = 0; i < handleBytes.length; i++) {
                if (handleBytes[i] == bytes1('.')) { // Compare with a byte literal using bytes1()
                    dotCount++;
                }
            }
            return dotCount;
        }

        function hasHyphenBeforeDot(string memory str) internal pure returns (bool) {
            bytes memory bytesStr = bytes(str);
            for (uint256 i = 0; i < bytesStr.length - 1; i++) {
                if (bytesStr[i] == "-" && bytesStr[i + 1] == ".") {
                    return true;
                }
            }
            return false;
        }

        function subhandlePart(string memory handleName) internal pure returns (string memory) {
            bytes memory handleBytes = bytes(handleName);
            uint256 lastDotIndex = findLastDot(handleBytes);

            return substring(handleName, 0, lastDotIndex);
        }

        function parentPart(string memory handleName) internal pure returns (string memory) {
            bytes memory handleBytes = bytes(handleName);
            uint256 lastDotIndex = findLastDot(handleBytes);

            return substring(handleName, lastDotIndex + 1, handleBytes.length - lastDotIndex - 1);
        }

        function findLastDot(bytes memory handleBytes) internal pure returns (uint256) {
            for (uint256 i = handleBytes.length - 1; i >= 0; i--) {
                if (handleBytes[i] == '.') {
                    return i;
                }
            }
            return 0;
        }

        function substring(string memory str, uint256 startIndex, uint256 length) internal pure returns (string memory) {
            bytes memory strBytes = bytes(str);
            require(startIndex + length <= strBytes.length, "Invalid substring length");

            bytes memory result = new bytes(length);
            for (uint256 i = 0; i < length; i++) {
                result[i] = strBytes[startIndex + i];
            }

            return string(result);
        }

        function stringToAddress(string memory _str) internal pure returns (address) {
            bytes memory data = bytes(_str);
            uint256 result = 0;
            for (uint256 i = 0; i < data.length; i++) {
                uint256 val = uint256(uint8(data[i]));
                if (val >= 48 && val <= 57) {
                    result = result * 16 + (val - 48);
                } else if (val >= 65 && val <= 70) {
                    result = result * 16 + (val - 55);
                } else if (val >= 97 && val <= 102) {
                    result = result * 16 + (val - 87);
                } else {
                    revert("Invalid address string");
                }
            }
            return address(uint160(result));
        }

        function splitCombinedHandleName(string memory combinedName) internal pure returns (string memory, string memory) {
            bytes memory combinedBytes = bytes(combinedName);
            uint256 dotIndex = findLastDot(combinedBytes);

            string memory subhandleName = substring(combinedName, 0, dotIndex);
            string memory parentHandleName = substring(combinedName, dotIndex + 1, combinedBytes.length - dotIndex - 1);

            return (subhandleName, parentHandleName);
        }
        


    }
// File: @openzeppelin/contracts/utils/math/SignedMath.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}

// File: @openzeppelin/contracts/utils/math/Math.sol


// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}

// File: @openzeppelin/contracts/utils/Strings.sol


// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)

pragma solidity ^0.8.0;



/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMath.abs(value))));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/Whitelist.sol


pragma solidity ^0.8.9;


contract Whitelist is Ownable {
    mapping(address => bool) public whitelist;

    event AddressAddedToWhitelist(address indexed account);
    event AddressRemovedFromWhitelist(address indexed account);

    function addAddressesToWhitelist(
        address account1,
        address account2,
        address account3,
        address account4,
        address account5,
        address account6,
        address account7,
        address account8,
        address account9,
        address account10
    ) external onlyOwner {
        addToWhitelist(account1);
        addToWhitelist(account2);
        addToWhitelist(account3);
        addToWhitelist(account4);
        addToWhitelist(account5);
        addToWhitelist(account6);
        addToWhitelist(account7);
        addToWhitelist(account8);
        addToWhitelist(account9);
        addToWhitelist(account10);
    }

    function addToWhitelist(address account) public onlyOwner {
        whitelist[account] = true;
        emit AddressAddedToWhitelist(account);
    }

    function removeFromWhitelist(address account) external onlyOwner {
        delete whitelist[account];
        emit AddressRemovedFromWhitelist(account);
    }

    function isWhitelisted(address account) public view returns (bool) {
        return whitelist[account];
    }
}

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// File: @openzeppelin/contracts/token/ERC721/ERC721.sol


// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;








/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner or approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId, 1);

        // Check that tokenId was not minted by `_beforeTokenTransfer` hook
        require(!_exists(tokenId), "ERC721: token already minted");

        unchecked {
            // Will not overflow unless all 2**256 token ids are minted to the same owner.
            // Given that tokens are minted one by one, it is impossible in practice that
            // this ever happens. Might change if we allow batch minting.
            // The ERC fails to describe this case.
            _balances[to] += 1;
        }

        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId, 1);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId, 1);

        // Update ownership in case tokenId was transferred by `_beforeTokenTransfer` hook
        owner = ERC721.ownerOf(tokenId);

        // Clear approvals
        delete _tokenApprovals[tokenId];

        unchecked {
            // Cannot overflow, as that would require more tokens to be burned/transferred
            // out than the owner initially received through minting and transferring in.
            _balances[owner] -= 1;
        }
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId, 1);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId, 1);

        // Check that tokenId was not transferred by `_beforeTokenTransfer` hook
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");

        // Clear approvals from the previous owner
        delete _tokenApprovals[tokenId];

        unchecked {
            // `_balances[from]` cannot overflow for the same reason as described in `_burn`:
            // `from`'s balance is the number of token held, which is at least one before the current
            // transfer.
            // `_balances[to]` could overflow in the conditions described in `_mint`. That would require
            // all 2**256 token ids to be minted, which in practice is impossible.
            _balances[from] -= 1;
            _balances[to] += 1;
        }
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId, 1);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens will be transferred to `to`.
     * - When `from` is zero, the tokens will be minted for `to`.
     * - When `to` is zero, ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual {}

    /**
     * @dev Hook that is called after any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens were transferred to `to`.
     * - When `from` is zero, the tokens were minted for `to`.
     * - When `to` is zero, ``from``'s tokens were burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual {}

    /**
     * @dev Unsafe write access to the balances, used by extensions that "mint" tokens using an {ownerOf} override.
     *
     * WARNING: Anyone calling this MUST ensure that the balances remain consistent with the ownership. The invariant
     * being that for any address `a` the value returned by `balanceOf(a)` must be equal to the number of tokens such
     * that `ownerOf(tokenId)` is `a`.
     */
    // solhint-disable-next-line func-name-mixedcase
    function __unsafe_increaseBalance(address account, uint256 amount) internal {
        _balances[account] += amount;
    }
}

// File: contracts/HNDL.sol


pragma solidity ^0.8.9;





contract HNDL is Ownable, ERC721 {
    
    address public feeRecipient;
    Whitelist private whitelistContract;
    
    uint256 private immutable ONE_YEAR_IN_SECONDS = 365 days;
    uint256 private immutable MAX_CHARACTER_LENGTH = 18;
    uint256 private immutable MINIMUM_CHARACTER_COUNT = 1;

    bytes private constant HANDLE_SUFFIX = hex"e282bf"; // ".₿" in UTF-8 encoding
    uint256 private fees;
    uint256 public _totalSupply;
    uint256 public contractDeploymentTime; // Deployment time proxy
    uint256 immutable HALVING_PERIOD = 252288000; // Approximately 8 years in seconds

    // Structs
    struct Handle {
        uint256 tokenId;
        uint256 expirationTimestamp;
        address parentOwner;
        uint256 subhandleCount;
        mapping(string => Subhandle) subhandles;
        uint256 registrationYears;
        string bitcoinAddress;
    }

    struct Subhandle {
        uint256 tokenId;
        address owner;
        uint256 expirationTimestamp;
        bool requested;
        uint256 registrationYears;
        string bitcoinAddress;
    }

    struct HandleInfo {
        uint256 tokenId;
        address owner;
        uint256 expirationTimestamp;
        uint256 subhandleCount;
        string bitcoinAddress;
    }

    struct SubhandleInfo {
        uint256 tokenId;
        address owner;
        uint256 expirationTimestamp;
        address parentHandleOwner;
        string bitcoinAddress;
    }

    struct ParentHandle {
        address parentOwner;
        bool permissionEnabled;
    }

    // Mappings
    mapping(string => Handle) private handles;
    mapping(uint256 => string) private handleNames;
    mapping(address => mapping(string => ParentHandle)) private parentHandleOwners;
    mapping(string => uint256) private tokenIds;
    mapping(uint256 => uint256) private parentTokenIds;
    mapping(uint256 => address) private parentOwners;
    mapping(address => uint256) private whitelistedMints;
    mapping(address => uint256) private freeWhitelistMints;
    mapping(address => uint256) private paidWhitelistMints;
    mapping(address => uint256) private feeBalances;

    // Events
    event HandleRegistered(
        address indexed owner,
        string handleName,
        uint256 expirationTimestamp,
        uint256 indexed tokenId

    );

    event HandleRenewed(
        address renewedBy,
        address indexed owner,
        string handleName,
        uint256 newExpirationTimestamp,
        uint256 indexed tokenId
    );

    event SubhandleRegistered(
        address indexed owner,
        string subhandleName,
        string parentHandleName,
        address parentOwner,
        uint256 expirationTimestamp,
        uint256 indexed tokenId
    );

    event SubhandleRenewed(
        address renewedBy,
        address indexed owner,
        string subhandleName,
        string parentHandleName,
        address indexed parentOwner,
        uint256 newExpirationTimestamp,
        uint256 indexed tokenId
    );

    event SubhandlePermissionToggled(
        address indexed owner,
        string parentHandleName,
        bool permissionEnabled,
        uint256 indexed tokenId
    );

    event HandleTransferred(
        address indexed previousOwner,
        string handleOrSubhandleName,
        address indexed newOwner,
        uint256 indexed tokenId
    );

    event HandleBurned(
        address indexed owner, 
        string handleName,
        uint256 indexed tokenId
    );

    event SubhandleBurned(
        address indexed owner, 
        string subhandleName,
        uint256 indexed tokenId
    );

    event BtcAddressHandleSet(
        address indexed setter,
        string handleName,
        string bitcoinAddress,
        uint256 indexed tokenId
    );

    event BtcAddressSubhandleSet(
        address indexed setter,
        string subhandleName,
        string bitcoinAddress,
        uint256 indexed tokenId
    );

    mapping(uint256 => uint256) private handleFees;
    mapping(uint256 => uint256) private subhandleFees;
    
    constructor(address _feeRecipient, address _whitelistAddress) Ownable() ERC721("HNDL", ".\xE2\x82\xBF") {

        feeRecipient = _feeRecipient;
        whitelistContract = Whitelist(_whitelistAddress);
        contractDeploymentTime = block.timestamp; // Set the deployment timestamp

        // Initialize handle fees for character counts 1 to 4
        handleFees[1] = 1000000000000000000 wei;
        handleFees[2] = 250000000000000000 wei;
        handleFees[3] = 15000000000000000 wei;
        handleFees[4] = 5000000000000000 wei;

        // Initialize subhandle fees for character counts 1 to 4
        subhandleFees[1] = 100000000000000000 wei;
        subhandleFees[2] = 25000000000000000 wei;
        subhandleFees[3] = 5000000000000000 wei;
        subhandleFees[4] = 2500000000000000 wei;

        // Initialize handle and subhandle fees for character counts 5 to 18
        for (uint256 i = 5; i <= 18; i++) {
            handleFees[i] = 100000000000000 wei;
            subhandleFees[i] = 100000000000000 wei;
        }
    }

    function calculateFee(uint256 characterCount, uint256 registrationYears, bool isSubhandle) internal view returns (uint256) {
        require(characterCount >= MINIMUM_CHARACTER_COUNT && characterCount <= MAX_CHARACTER_LENGTH, "Invalid character count");

        uint256 timeElapsed = block.timestamp - contractDeploymentTime;
        uint256 halvingCount = timeElapsed / HALVING_PERIOD; // Approximately 8 years
        
        // Limit the number of halving count to 8, approxmiately 64 years
        halvingCount = halvingCount > 8 ? 8 : halvingCount;

        uint256 fee = isSubhandle ? subhandleFees[characterCount] : handleFees[characterCount];
        fee = fee * registrationYears;

        // Adjust the fee based on halvings occurred
        fee = fee / (2 ** halvingCount);

        return fee;
    }

    function calculateHandleFee(uint256 characterCount, uint256 registrationYears) public view returns (uint256) {
        return calculateFee(characterCount, registrationYears, false);
    }

    function calculateSubhandleFee(uint256 characterCount, uint256 registrationYears) public view returns (uint256) {
        return calculateFee(characterCount, registrationYears, true);
    }

    function updateFeeRecipient(address newFeeRecipient) external onlyOwner {
        require(newFeeRecipient != address(0), "Invalid address");
        feeRecipient = newFeeRecipient;
    }

    modifier validHandleName(string memory handleName) {
        require(
            !StringUtil.hasConsecutiveHyphens(handleName) || StringUtil.hasValidPrefix(handleName),
            
            "Handle cannot contain consecutive hyphens"
        );
        _;
    }

    modifier validHyphenAndDot(string memory handleName) {
        require(
            !(StringUtil.hasHyphenBeforeDot(handleName) || StringUtil.countDots(handleName) > 1),
            "Handle cannot start or end with a hyphen or dot"
            
        );
        _;
    }

    modifier noDot(string memory _handle) {
        require(!StringUtil.containsSpecialCharacters(_handle, "."), "Handle cannot contain '.'");

        _;
    }

    modifier validMainPart(string memory handleName) {
        bytes memory handleBytes = bytes(handleName);

        // Regular expression pattern to match only alphanumeric characters, hyphens, and dot (.)
        bytes memory allowedPattern = abi.encodePacked("0123456789abcdefghijklmnopqrstuvwxyz-."); 

        require(handleBytes.length > 0, "Handle name must not be empty");

        // Check for consecutive dots
        for (uint256 i = 1; i < handleBytes.length; i++) {
            require(!(handleBytes[i] == '.' && handleBytes[i - 1] == '.'), "Handle cannot contain consecutive dots");
        }

        for (uint256 i = 0; i < handleBytes.length; i++) {
            bytes1 character = handleBytes[i];
            bool isAllowedCharacter = false;
            for (uint256 j = 0; j < allowedPattern.length; j++) {
                if (character == allowedPattern[j]) {
                    isAllowedCharacter = true;
                    break;
                }
            }
            require(isAllowedCharacter, "Invalid character in handle name");
        }

        // Check if the handle starts or ends with a hyphen or dot
        require(handleBytes[0] != '-' && handleBytes[0] != '.' && handleBytes[handleBytes.length - 1] != '-' && handleBytes[handleBytes.length - 1] != '.', "Handle cannot start or end with a hyphen or dot");

        _;
    }

    function toggleSubhandlePermission(string memory parentHandleName) external { 
        require(bytes(parentHandleName).length > 0, "Invalid parent handle name");

        string memory parentHandleWithSuffix = string(abi.encodePacked(parentHandleName, ".", string(HANDLE_SUFFIX)));

        Handle storage parentHandle = handles[parentHandleWithSuffix];
        require(parentHandle.tokenId != 0, "Parent handle not registered");
        require(msg.sender == parentHandle.parentOwner, "Only the parent handle owner can toggle permission");

        ParentHandle storage parentPermissions = parentHandleOwners[msg.sender][parentHandleWithSuffix];
        parentPermissions.permissionEnabled = !parentPermissions.permissionEnabled;

        uint256 tokenId = parentHandle.tokenId; // Fixed typo here

        // Emit the event with the parent handle name including the suffix
        emit SubhandlePermissionToggled(
            msg.sender, // Owner address
            parentHandleWithSuffix, // Parent handle name including the suffix
            parentPermissions.permissionEnabled, // Permission enabled flag
            tokenId
        );
    }

    function isPermissionEnabled(string memory parentHandleName, address parentOwner) internal view returns (bool) {
        ParentHandle storage parentPermissions = parentHandleOwners[parentOwner][parentHandleName];
        return parentPermissions.permissionEnabled;
    }

    function isSubhandlePermissionEnabled(string memory parentHandleName) external view returns (bool) {
        require(bytes(parentHandleName).length > 0, "Invalid parent handle name");

        string memory parentHandleWithSuffix = string(abi.encodePacked(parentHandleName, ".", string(HANDLE_SUFFIX)));

        Handle storage parentHandle = handles[parentHandleWithSuffix];
        require(parentHandle.tokenId != 0, "Parent handle not registered");

        ParentHandle storage parentPermissions = parentHandleOwners[parentHandle.parentOwner][parentHandleWithSuffix];
        return parentPermissions.permissionEnabled;
    }

    modifier onlyParentOwner(uint256 tokenId) {
        require(msg.sender == parentOwners[tokenId], "Not handle owner");
        _;
    }

    // Function to withdraw handle fees by parent owner
    function withdrawHandleFees(uint256 tokenId) public onlyParentOwner(tokenId) {
        // Transfer handle fees to owner
        payable(parentOwners[tokenId]).transfer(handleFees[tokenId]);
    }

    function isWhitelisted(address account) public view returns (bool) {
        return whitelistContract.isWhitelisted(account);
    }

    function burnHandle(uint256 tokenId) internal {
        string memory handleWithSuffix = handleNames[tokenId];
        Handle storage handle = handles[handleWithSuffix];

        require(handle.tokenId != 0, "Handle not registered");
        require(handle.expirationTimestamp <= block.timestamp, "Handle is not expired");
        
        address owner = ownerOf(tokenId);
        require(owner == handle.parentOwner, "Only parent owner can burn expired handle");

        // Burn the token
        _burn(tokenId);

        emit HandleBurned(owner, handleWithSuffix, tokenId);
    }

    function burnSubhandle(string memory subhandleAndParent) internal {
        (string memory subhandleName, string memory parentHandleName) = StringUtil.splitCombinedHandleName(subhandleAndParent);
        string memory parentHandleWithSuffix = string(abi.encodePacked(parentHandleName, ".", string(HANDLE_SUFFIX)));
        Subhandle storage subhandle = handles[parentHandleWithSuffix].subhandles[subhandleName];

        require(subhandle.tokenId != 0, "Subhandle not registered");
        require(subhandle.expirationTimestamp <= block.timestamp, "Subhandle is not expired");

        address owner = ownerOf(subhandle.tokenId);
        require(owner == subhandle.owner, "Only subhandle owner can burn expired subhandle");

        // Burn the token
        _burn(subhandle.tokenId);

        string memory subhandleWithSuffix = string(abi.encodePacked(subhandleName, ".", parentHandleWithSuffix));
        emit SubhandleBurned(owner, subhandleWithSuffix, subhandle.tokenId);
    }

    function mintHandle(
        string memory handleName,
        uint256 registrationYears
    ) external payable noDot(handleName) validMainPart(handleName) validHandleName(handleName) {
        // Check if the handle with suffix is already registered
        string memory parentHandleWithSuffix = string(abi.encodePacked(handleName, ".", string(HANDLE_SUFFIX)));
        Handle storage handle = handles[parentHandleWithSuffix];
        
        bool isExpired = (handle.tokenId != 0 && handle.expirationTimestamp <= block.timestamp);
        
        if (handle.tokenId == 0 || isExpired) {
            uint256 characterCount = bytes(handleName).length; // Calculate the character count
            uint256 registrationFee = calculateHandleFee(characterCount, registrationYears); // Calculate the registration fee

            // Check if the user is whitelisted
            bool isWhitelistedUser = whitelistContract.isWhitelisted(msg.sender);

            // Check for free mint eligibility
            if (isWhitelistedUser && registrationYears == 1 && characterCount >= 4 && freeWhitelistMints[msg.sender] < 3) {
                // Mint free handle
                freeWhitelistMints[msg.sender]++;
            } else if (msg.value >= registrationFee) {
                // Mint paid handle
                paidWhitelistMints[msg.sender]++;
            } else {
                revert("Insufficient registration fee or not eligible for free mint");
            }

            // Burn expired handle if applicable
            if (isExpired) {
                burnHandle(handle.tokenId); // Burn the expired token
            }

            // Generate a new token ID for the claimed handle
            uint256 tokenId = _totalSupply + 1;
            _totalSupply += 1;
            _mint(msg.sender, tokenId);

            Handle storage newHandle = handles[parentHandleWithSuffix];
            newHandle.tokenId = tokenId;
            newHandle.expirationTimestamp = block.timestamp + (ONE_YEAR_IN_SECONDS * registrationYears);
            newHandle.parentOwner = msg.sender;
            newHandle.registrationYears = registrationYears;

            handleNames[tokenId] = parentHandleWithSuffix;
            tokenIds[parentHandleWithSuffix] = tokenId;

            // Handle payment if it's a paid mint
            if (!isWhitelistedUser) {
                // Transfer the registration fee directly to the feeRecipient address
                payable(feeRecipient).transfer(msg.value);
            }

            emit HandleRegistered(
                msg.sender,
                parentHandleWithSuffix,
                newHandle.expirationTimestamp,
                tokenId
            );

            // Check if the handle was expired and claimed
            if (isExpired) {

            }
        } else {
            revert("Handle already registered and not expired");
        }
    }

    function mintSubhandle(
        string memory subhandleAndParent,
        uint256 registrationYears
    ) external payable validMainPart(subhandleAndParent) validHyphenAndDot(subhandleAndParent) {
        string memory subhandleName = StringUtil.subhandlePart(subhandleAndParent);

        string memory parentHandleWithSuffix = string(abi.encodePacked(StringUtil.parentPart(subhandleAndParent), ".", string(HANDLE_SUFFIX)));
        Handle storage parentHandle = handles[parentHandleWithSuffix];
        Subhandle storage subhandle = parentHandle.subhandles[subhandleName];

        bool isParentExpired = (parentHandle.expirationTimestamp <= block.timestamp);
        bool isSubhandleExpired = (subhandle.tokenId != 0 && subhandle.expirationTimestamp <= block.timestamp);

        require(!isParentExpired, "Parent handle is expired");
        require(subhandle.tokenId == 0 || isSubhandleExpired, "Subhandle already registered and not expired");

        uint256 characterCount = bytes(subhandleName).length;
        uint256 registrationFee = calculateSubhandleFee(characterCount, registrationYears);

        bool isParentOwner = (msg.sender == parentHandle.parentOwner);
        if (!isParentOwner) {
            require(msg.value >= registrationFee, "Insufficient registration fee");
            address payable parentOwner = payable(parentHandle.parentOwner);
            parentOwner.transfer(msg.value);
        }

        require(!subhandle.requested, "Subhandle request is pending");
        require(
            isPermissionEnabled(parentHandleWithSuffix, parentHandle.parentOwner) || isParentOwner,
            "Permission not granted"
        );

        require(
            !isParentOwner || registrationYears <= 1,
            "Maximum registration years for parent handle owner is 1"
        );

        // Burn expired subhandle if applicable
        if (isSubhandleExpired) {
            burnSubhandle(subhandleAndParent); // Burn the expired token
        }

        // Check for consecutive hyphens
        require(
            !StringUtil.hasConsecutiveHyphens(subhandleName) || StringUtil.hasValidPrefix(subhandleName),
            "Subhandle cannot contain consecutive hyphens"
        );

        // Generate a new token ID for the claimed subhandle
        uint256 tokenId = _totalSupply + 1;
        _totalSupply += 1;
        _mint(msg.sender, tokenId);

        subhandle.tokenId = tokenId;
        subhandle.owner = msg.sender;
        subhandle.requested = false;
        subhandle.expirationTimestamp = block.timestamp + (ONE_YEAR_IN_SECONDS * registrationYears);
        subhandle.registrationYears = registrationYears;

        parentHandle.subhandleCount += 1;

        string memory subhandleWithSuffix = string(abi.encodePacked(subhandleName, ".", parentHandleWithSuffix));
        handleNames[tokenId] = subhandleWithSuffix;
        tokenIds[subhandleWithSuffix] = tokenId;

        uint256 expirationTimestamp = subhandle.expirationTimestamp;
        emit SubhandleRegistered(
            msg.sender,
            subhandleWithSuffix,
            parentHandleWithSuffix,
            parentHandle.parentOwner,
            expirationTimestamp,
            tokenId
        );
    }

    function renewHandle(string memory handleName, uint256 additionalYears) external payable { 
        string memory parentHandleWithSuffix = string(abi.encodePacked(handleName, ".", string(HANDLE_SUFFIX)));

        uint256 fee = calculateHandleFee(bytes(parentHandleWithSuffix).length, additionalYears);
        require(msg.value >= fee, "Insufficient fee");

        Handle storage handle = handles[parentHandleWithSuffix];
        require(handle.tokenId != 0, "Handle not registered");

        // Check if the parent handle is expired
        require(handle.expirationTimestamp > block.timestamp, "Handle has expired, claim this handle using the mint function.");

        // Update expiration
        handle.expirationTimestamp += additionalYears * ONE_YEAR_IN_SECONDS;

        // Transfer fee
        payable(feeRecipient).transfer(msg.value);

        uint256 tokenId = handle.tokenId;

        // Emit event
        emit HandleRenewed(
            msg.sender, //renewedBy
            ownerOf(handle.tokenId),
            parentHandleWithSuffix,
            handle.expirationTimestamp,
            tokenId
        );
    }

    function renewSubhandle(
        string memory subhandleAndParent,
        uint256 additionalYears
    ) external payable {
        require(additionalYears > 0, "Invalid additional years");

        // Similar to the original code, get subhandle and parent handle names
        string memory subhandleName = StringUtil.subhandlePart(subhandleAndParent);
        string memory parentHandleWithSuffix = string(abi.encodePacked(StringUtil.parentPart(subhandleAndParent), ".", string(HANDLE_SUFFIX)));

        // Check if subhandle and parent handle names are valid
        require(bytes(subhandleName).length > 0 && bytes(parentHandleWithSuffix).length > 0, "Invalid subhandle and parent handle");
        require(handles[parentHandleWithSuffix].tokenId != 0, "Parent handle not registered");

        // Get the subhandle struct
        Subhandle storage subhandle = handles[parentHandleWithSuffix].subhandles[subhandleName];
        require(subhandle.tokenId != 0, "Subhandle not registered");

        // Check if the subhandle is expired
        require(subhandle.expirationTimestamp > block.timestamp, "Subhandle has expired, claim this subhandle using the mint function");

        // Calculate the renewal fee for the entire renewal period
        uint256 characterCount = bytes(subhandleName).length;
        uint256 renewalFee = calculateSubhandleFee(characterCount, additionalYears);

        // Check if the caller is not the owner of the parent handle
        bool isParentOwner = (msg.sender == handles[parentHandleWithSuffix].parentOwner);
        if (!isParentOwner) {
            require(msg.value >= renewalFee, "Insufficient renewal fee");

            // Transfer the total renewal fee to the parent handle owner
            address payable parentOwner = payable(handles[parentHandleWithSuffix].parentOwner);
            parentOwner.transfer(msg.value);
        }

        require(
            !isParentOwner || additionalYears <= 1,
            "Maximum renewal years for parent handle owner is 1"
        );

        // Extend the expiration timestamp of the subhandle for the entire renewal period
        subhandle.expirationTimestamp += ONE_YEAR_IN_SECONDS * additionalYears;

        uint256 tokenId = subhandle.tokenId;

        // Update handle and subhandle name mappings with suffix
        string memory subhandleWithSuffix = string(abi.encodePacked(subhandleName, ".", parentHandleWithSuffix));
        handleNames[subhandle.tokenId] = subhandleWithSuffix;
        tokenIds[subhandleWithSuffix] = subhandle.tokenId;
        tokenIds[subhandleWithSuffix] = tokenId;

        emit SubhandleRenewed(
            msg.sender, //renewedBy
            ownerOf(subhandle.tokenId),
            subhandleWithSuffix,
            parentHandleWithSuffix,
            handles[parentHandleWithSuffix].parentOwner,
            subhandle.expirationTimestamp,
            tokenId
        );
    }

    function setBitcoinAddressForHandle(string memory handleName, string memory bitcoinAddress) external {

        address sender = msg.sender;

        // Form the full handle name with suffix
        string memory handleWithSuffix = string(abi.encodePacked(handleName, ".", string(HANDLE_SUFFIX)));

        // Access the handle struct
        Handle storage handle = handles[handleWithSuffix];

        // Validate handle existence
        require(handle.tokenId != 0, "Handle does not exist");

        // Validate ownership
        require(sender == ownerOf(handle.tokenId), "Only the current owner can set the Bitcoin address");

        // Check handle expiration
        require(handle.expirationTimestamp > block.timestamp, "Handle has expired");

        // Update the Bitcoin address for the handle
        handle.bitcoinAddress = bitcoinAddress;

        // Emit an event to reflect the update
        string memory parentHandleWithSuffix = string(abi.encodePacked(handleName, ".", string(HANDLE_SUFFIX)));
        uint256 tokenId = handle.tokenId;
        emit BtcAddressHandleSet(sender, parentHandleWithSuffix, bitcoinAddress, tokenId);
    }

    function setBitcoinAddressForSubhandle(string memory subhandleAndParent, string memory bitcoinAddress) external {

        string memory parentHandleWithSuffix = string(abi.encodePacked(StringUtil.parentPart(subhandleAndParent), ".", string(HANDLE_SUFFIX)));
        string memory subhandleName = StringUtil.subhandlePart(subhandleAndParent);

        // Validate parent handle existence
        require(handles[parentHandleWithSuffix].tokenId != 0, "Parent handle does not exist");

        // Validate subhandle existence and expiration
        Subhandle storage subhandle = handles[parentHandleWithSuffix].subhandles[subhandleName];
        require(subhandle.tokenId != 0, "Subhandle does not exist");
        require(subhandle.expirationTimestamp > block.timestamp, "Subhandle has expired");

        // Validate ownership
        require(msg.sender == ownerOf(subhandle.tokenId), "You must be the owner of the subhandle to set the Bitcoin address");

        subhandle.bitcoinAddress = bitcoinAddress;
        string memory subhandleWithSuffix = string(abi.encodePacked(subhandleName, ".", parentHandleWithSuffix));
        uint256 tokenId = subhandle.tokenId;

        emit BtcAddressSubhandleSet(msg.sender, subhandleWithSuffix, bitcoinAddress, tokenId);
    }

   enum TransferType {
        PARENT,
        SUBHANDLE
    }

    function safeTransferFrom( 
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        TransferType transferType;

        if (parentTokenIds[tokenId] != 0) {
            transferType = TransferType.SUBHANDLE;
        } else {
            transferType = TransferType.PARENT;
        }

        if (transferType == TransferType.PARENT) {
            Handle storage handle = handles[handleNames[tokenId]];
            address currentOwner = handle.parentOwner;
            require(currentOwner != to, "New owner is same as current owner");
            handle.parentOwner = to;

            emit HandleTransferred(
                from,
                handleNames[tokenId],
                to,
                tokenId
            );
        } else if (transferType == TransferType.SUBHANDLE) {
            Subhandle storage subhandle = handles[handleNames[parentTokenIds[tokenId]]].subhandles[StringUtil.subhandlePart(handleNames[tokenId])];
            address currentOwner = subhandle.owner;
            require(currentOwner != to, "New owner is same as current owner");
            subhandle.owner = to;

            emit HandleTransferred(
                subhandle.owner, 
                StringUtil.subhandlePart(handleNames[tokenId]),
                to,
                tokenId
            );

        }

        super.safeTransferFrom(from, to, tokenId, _data);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        TransferType transferType;

        if (parentTokenIds[tokenId] != 0) {
            transferType = TransferType.SUBHANDLE;
        } else {
            transferType = TransferType.PARENT;
        }

        if (transferType == TransferType.PARENT) {
            Handle storage handle = handles[handleNames[tokenId]];
            address currentOwner = handle.parentOwner;
            require(currentOwner != to, "New owner is same as current owner");
            handle.parentOwner = to;

            emit HandleTransferred(
                from,
                handleNames[tokenId],
                to,
                tokenId
            );
        } else if (transferType == TransferType.SUBHANDLE) {
            Subhandle storage subhandle = handles[handleNames[parentTokenIds[tokenId]]].subhandles[StringUtil.subhandlePart(handleNames[tokenId])];
            address currentOwner = subhandle.owner;
            require(currentOwner != to, "New owner is same as current owner");
            subhandle.owner = to;

            emit HandleTransferred(
                subhandle.owner,
                StringUtil.subhandlePart(handleNames[tokenId]),
                to,
                tokenId
            );
        }

        super.transferFrom(from, to, tokenId);
    }

    function getHandleInfo(string memory handleName) external view returns (HandleInfo memory) {
        string memory parentHandleWithSuffix = string(abi.encodePacked(handleName, ".", string(HANDLE_SUFFIX)));
        Handle storage handle = handles[parentHandleWithSuffix];
        
        require(handle.tokenId != 0, "Handle token does not exist");
        
        address currentOwner = ownerOf(handle.tokenId);
        
        return HandleInfo(
            handle.tokenId,
            currentOwner,
            handle.expirationTimestamp,
            handle.subhandleCount,
            handle.bitcoinAddress
        );
    }

    function getSubhandleInfo(string memory subhandleAndParent) external view returns (SubhandleInfo memory) {
        (string memory subhandleName, string memory parentHandleName) = StringUtil.splitCombinedHandleName(subhandleAndParent);
        string memory parentHandleWithSuffix = string(abi.encodePacked(parentHandleName, ".", string(HANDLE_SUFFIX)));
        Subhandle storage subhandle = handles[parentHandleWithSuffix].subhandles[subhandleName];
        
        require(subhandle.tokenId != 0, "Subhandle token does not exist");
        
        address subhandleOwner = ownerOf(subhandle.tokenId);
        address parentHandleOwner = ownerOf(handles[parentHandleWithSuffix].tokenId);

        return SubhandleInfo(
            subhandle.tokenId,
            subhandleOwner,
            subhandle.expirationTimestamp,
            parentHandleOwner,
            subhandle.bitcoinAddress
        );
    }

}
    

    
