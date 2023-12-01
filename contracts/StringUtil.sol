// SPDX-License-Identifier: MIT
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