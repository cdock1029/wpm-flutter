import * as validator from 'validator';

/**
 * Typings for https://github.com/chriso/validator.js
 */
export interface IValidator {
  /**
   * check if the string contains the seed.
   */
  contains(str: string, seed: string): boolean;
  /**
   * check if the string matches the comparison.
   */
  equals(str: string, comparison: string): boolean;
  /**
   * check if the string is a date that's after the specified date (defaults to now).
   */
  isAfter(str: string, date: Date): boolean;
  /**
   * check if the string contains only letters (a-zA-Z).<br/><br/>Locale is one of `['ar', 'ar-AE', 'ar-BH', 'ar-DZ', 'ar-EG', 'ar-IQ', 'ar-JO', 'ar-KW', 'ar-LB', 'ar-LY', 'ar-MA', 'ar-QA', 'ar-QM', 'ar-SA', 'ar-SD', 'ar-SY', 'ar-TN', 'ar-YE', 'bg-BG', 'cs-CZ', 'da-DK', 'de-DE', 'el-GR', 'en-AU', 'en-GB', 'en-HK', 'en-IN', 'en-NZ', 'en-US', 'en-ZA', 'en-ZM', 'es-ES', 'fr-FR', 'hu-HU', 'it-IT', 'nb-NO', 'nl-NL', 'nn-NO', 'pl-PL', 'pt-BR', 'pt-PT', 'ru-RU', 'sk-SK', 'sr-RS', 'sr-RS@latin', 'sv-SE', 'tr-TR', 'uk-UA']`) and defaults to `en-US`.
   */
  isAlpha(str: string, local: string): boolean;
  /**
   * check if the string contains only letters and numbers.<br/><br/>Locale is one of `['ar', 'ar-AE', 'ar-BH', 'ar-DZ', 'ar-EG', 'ar-IQ', 'ar-JO', 'ar-KW', 'ar-LB', 'ar-LY', 'ar-MA', 'ar-QA', 'ar-QM', 'ar-SA', 'ar-SD', 'ar-SY', 'ar-TN', 'ar-YE', 'bg-BG', 'cs-CZ', 'da-DK', 'de-DE', 'el-GR', 'en-AU', 'en-GB', 'en-HK', 'en-IN', 'en-NZ', 'en-US', 'en-ZA', 'en-ZM', 'es-ES', 'fr-FR', 'hu-HU', 'it-IT', 'nb-NO', 'nl-NL', 'nn-NO', 'pl-PL', 'pt-BR', 'pt-PT', 'ru-RU', 'sk-SK', 'sr-RS', 'sr-RS@latin', 'sv-SE', 'tr-TR', 'uk-UA']`) and defaults to `en-US`.
   */
  isAlphanumeric(str: string, local: string): boolean;
  /**
   * check if the string contains ASCII chars only.
   */
  isAscii(str: string): boolean;
  /**
   * check if a string is base64 encoded.
   */
  isBase64(str: string): boolean;
  /**
   * check if the string is a date that's before the specified date.
   */
  isBefore(str: string, date: Date): boolean;
  /**
   * check if a string is a boolean.
   */
  isBoolean(str: string): boolean;
  /**
   * check if the string's length (in UTF-8 bytes) falls in a range.<br/><br/>`options` is an object which defaults to `{min:0, max: undefined}`.
   */
  isByteLength(str: string, options: any): boolean;
  /**
   * check if the string is a credit card.
   */
  isCreditCard(str: string): boolean;
  /**
   * check if the string is a valid currency amount.<br/><br/>`options` is an object which defaults to `{symbol: '$', require_symbol: false, allow_space_after_symbol: false, symbol_after_digits: false, allow_negatives: true, parens_for_negatives: false, negative_sign_before_digits: false, negative_sign_after_digits: false, allow_negative_sign_placeholder: false, thousands_separator: ',', decimal_separator: '.', allow_decimal: true, require_decimal: false, digits_after_decimal: [2], allow_space_after_digits: false}`.<br/>Note: The array `digits_after_decimal` is filled with the exact number of digits allowd not a range, for example a range 1 to 3 will be given as [1, 2, 3].
   */
  isCurrency(str: string, options?: any): boolean;
  /**
   * check if the string is a [data uri format](https://developer.mozilla.org/en-US/docs/Web/HTTP/data_URIs).
   */
  isDataURI(str: string): boolean;
  /**
   * check if the string represents a decimal number, such as 0.1, .3, 1.1, 1.00003, 4.0, etc.<br/><br/>`options` is an object which defaults to `{force_decimal: false, decimal_digits: '1,', locale: 'en-US'}`<br/><br/>`locale` determine the decimal separator and is one of `['ar', 'ar-AE', 'ar-BH', 'ar-DZ', 'ar-EG', 'ar-IQ', 'ar-JO', 'ar-KW', 'ar-LB', 'ar-LY', 'ar-MA', 'ar-QA', 'ar-QM', 'ar-SA', 'ar-SD', 'ar-SY', 'ar-TN', 'ar-YE', 'bg-BG', 'cs-CZ', 'da-DK', 'de-DE', 'en-AU', 'en-GB', 'en-HK', 'en-IN', 'en-NZ', 'en-US', 'en-ZA', 'en-ZM', 'es-ES', 'fr-FR', 'hu-HU', 'it-IT', 'nb-NO', 'nl-NL', 'nn-NO', 'pl-PL', 'pt-BR', 'pt-PT', 'ru-RU', 'sr-RS', 'sr-RS@latin', 'sv-SE', 'tr-TR', 'uk-UA']`.<br/>Note: `decimal_digits` is given as a range like '1,3', a specific value like '3' or min like '1,'.
   */
  isDecimal(str: string, options?: any): boolean;
  /**
   * check if the string is a number that's divisible by another.
   */
  isDivisibleBy(str: string, number: number): boolean;
  /**
   * check if the string is an email.<br/><br/>`options` is an object which defaults to `{ allow_display_name: false, require_display_name: false, allow_utf8_local_part: true, require_tld: true }`. If `allow_display_name` is set to true, the validator will also match `Display Name <email-address>`. If `require_display_name` is set to true, the validator will reject strings without the format `Display Name <email-address>`. If `allow_utf8_local_part` is set to false, the validator will not allow any non-English UTF8 character in email address' local part. If `require_tld` is set to false, e-mail addresses without having TLD in their domain will also be matched.
   */
  isEmail(str: string, options?: any): boolean;
  /**
   * check if the string has a length of zero.
   */
  isEmpty(str: string): boolean;
  /**
   * check if the string is a fully qualified domain name (e.g. domain.com).<br/><br/>`options` is an object which defaults to `{ require_tld: true, allow_underscores: false, allow_trailing_dot: false }`.
   */
  isFQDN(str: string, options?: any): boolean;
  /**
   * check if the string is a float.<br/><br/>`options` is an object which can contain the keys `min`, `max`, `gt`, and/or `lt` to validate the float is within boundaries (e.g. `{ min: 7.22, max: 9.55 }`) it also has `locale` as an option.<br/><br/>`min` and `max` are equivalent to 'greater or equal' and 'less or equal', respectively while `gt` and `lt` are their strict counterparts.<br/><br/>`locale` determine the decimal separator and is one of `['ar', 'ar-AE', 'ar-BH', 'ar-DZ', 'ar-EG', 'ar-IQ', 'ar-JO', 'ar-KW', 'ar-LB', 'ar-LY', 'ar-MA', 'ar-QA', 'ar-QM', 'ar-SA', 'ar-SD', 'ar-SY', 'ar-TN', 'ar-YE', 'bg-BG', 'cs-CZ', 'da-DK', 'de-DE', 'en-AU', 'en-GB', 'en-HK', 'en-IN', 'en-NZ', 'en-US', 'en-ZA', 'en-ZM', 'es-ES', 'fr-FR', 'hu-HU', 'it-IT', 'nb-NO', 'nl-NL', 'nn-NO', 'pl-PL', 'pt-BR', 'pt-PT', 'ru-RU', 'sr-RS', 'sr-RS@latin', 'sv-SE', 'tr-TR', 'uk-UA']`.
   */
  isFloat(str: string, options?: any): boolean;
  /**
   * check if the string contains any full-width chars.
   */
  isFullWidth(str: string): boolean;
  /**
   * check if the string contains any half-width chars.
   */
  isHalfWidth(str: string): boolean;
  /**
   * check if the string is a hash of type algorithm.<br/><br/>Algorithm is one of `['md4', 'md5', 'sha1', 'sha256', 'sha384', 'sha512', 'ripemd128', 'ripemd160', 'tiger128', 'tiger160', 'tiger192', 'crc32', 'crc32b']`
   */
  isHash(str: string, algorithm: string): boolean;
  /**
   * check if the string is a hexadecimal color.
   */
  isHexColor(str: string): boolean;
  /**
   * check if the string is a hexadecimal number.
   */
  isHexadecimal(str: string): boolean;
  /**
   * check if the string is an IP (version 4 or 6).
   */
  isIP(str: string, version: number): boolean;
  /**
   * check if the string is an ISBN (version 10 or 13).
   */
  isISBN(str: string, version: number): boolean;
  /**
   * check if the string is an [ISSN](https://en.wikipedia.org/wiki/International_Standard_Serial_Number).<br/><br/>`options` is an object which defaults to `{ case_sensitive: false, require_hyphen: false }`. If `case_sensitive` is true, ISSNs with a lowercase `'x'` as the check digit are rejected.
   */
  isISSN(str: string, options?: any): boolean;
  /**
   * check if the string is an [ISIN][ISIN] (stock/security identifier).
   */
  isISIN(str: string): boolean;
  /**
   * check if the string is a valid [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) date.
   */
  isISO8601(str: string): boolean;
  /**
   * check if the string is a valid [ISO 3166-1 alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) officially assigned country code.
   */
  isISO31661Alpha2(str: string): boolean;
  /**
   * check if the string is a [ISRC](https://en.wikipedia.org/wiki/International_Standard_Recording_Code).
   */
  isISRC(str: string): boolean;
  /**
   * check if the string is in a array of allowed values.
   */
  isIn(str: string, values: Array<any>): boolean;
  /**
   * check if the string is an integer.<br/><br/>`options` is an object which can contain the keys `min` and/or `max` to check the integer is within boundaries (e.g. `{ min: 10, max: 99 }`). `options` can also contain the key `allow_leading_zeroes`, which when set to false will disallow integer values with leading zeroes (e.g. `{ allow_leading_zeroes: false }`). Finally, `options` can contain the keys `gt` and/or `lt` which will enforce integers being greater than or less than, respectively, the value provided (e.g. `{gt: 1, lt: 4}` for a number between 1 and 4).
   */
  isInt(str: string, options?: any): boolean;
  /**
   * check if the string is valid JSON (note: uses JSON.parse).
   */
  isJSON(str: string): boolean;
  /**
   * check if the string is a valid latitude-longitude coordinate in the format `lat,long` or `lat, long`.
   */
  isLatLong(str: string): boolean;
  /**
   * check if the string's length falls in a range.<br/><br/>`options` is an object which defaults to `{min:0, max: undefined}`. Note: this function takes into account surrogate pairs.
   */
  isLength(str: string, options: any): boolean;
  /**
   * check if the string is lowercase.
   */
  isLowercase(str: string): boolean;
  /**
   * check if the string is a MAC address.
   */
  isMACAddress(str: string): boolean;
  /**
   * check if the string is a MD5 hash.
   */
  isMD5(str: string): boolean;
  /**
   * check if the string matches to a valid [MIME type](https://en.wikipedia.org/wiki/Media_type) format
   */
  isMimeType(str: string): boolean;
  /**
   * check if the string is a mobile phone number,<br/><br/>(locale is one of `['ar-AE', 'ar-DZ', 'ar-EG', 'ar-JO', 'ar-SA', 'ar-SY', 'be-BY', 'bg-BG', 'cs-CZ', 'de-DE', 'da-DK', 'el-GR', 'en-AU', 'en-CA', 'en-GB', 'en-HK', 'en-IN',  'en-KE', 'en-NG', 'en-NZ', 'en-RW', 'en-SG', 'en-UG', 'en-US', 'en-TZ', 'en-ZA', 'en-ZM', 'en-PK', 'es-ES', 'et-EE', 'fa-IR', 'fi-FI', 'fr-FR', 'he-IL', 'hu-HU', 'it-IT', 'ja-JP', 'kk-KZ', 'ko-KR', 'lt-LT', 'ms-MY', 'nb-NO', 'nn-NO', 'pl-PL', 'pt-PT', 'pt-BR', 'ro-RO', 'ru-RU', 'sk-SK', 'sr-RS', 'th-TH', 'tr-TR', 'uk-UA', 'vi-VN', 'zh-CN', 'zh-HK', 'zh-TW']` OR 'any'. If 'any' is used, function will check if any of the locales match).<br/><br/>`options` is an optional object that can be supplied with the following keys: `strictMode`, if this is set to `true`, the mobile phone number must be supplied with the country code and therefore must start with `+`.
   */
  isMobilePhone(str: string, locale: string): boolean;
  /**
   * check if the string is a valid hex-encoded representation of a [MongoDB ObjectId][mongoid].
   */
  isMongoId(str: string): boolean;
  /**
   * check if the string contains one or more multibyte chars.
   */
  isMultibyte(str: string): boolean;
  /**
   * check if the string contains only numbers.
   */
  isNumeric(str: string): boolean;
  /**
   * check if the string is a valid port number.
   */
  isPort(str: string): boolean;
  /**
   * check if the string is a postal code,<br/><br/>(locale is one of `[ 'AT', 'AU', 'BE', 'BG', 'CA', 'CH', 'CZ', 'DE', 'DK', 'DZ', 'ES', 'FI', 'FR', 'GB', 'GR', 'IL', 'IN', 'IS', 'IT', 'JP', 'KE', 'LI', 'MX', 'NL', 'NO', 'PL', 'PT', 'RO', 'RU', 'SA', 'SE', 'TW', 'US', 'ZA', 'ZM' ]` OR 'any'. If 'any' is used, function will check if any of the locals match).
   */
  isPostalCode(str: string, locale: string): boolean;
  /**
   * check if the string contains any surrogate pairs chars.
   */
  isSurrogatePair(str: string): boolean;
  /**
   * check if the string is an URL.<br/><br/>`options` is an object which defaults to `{ protocols: ['http','https','ftp'], require_tld: true, require_protocol: false, require_host: true, require_valid_protocol: true, allow_underscores: false, host_whitelist: false, host_blacklist: false, allow_trailing_dot: false, allow_protocol_relative_urls: false }`.
   */
  isURL(str: string, options?: any): boolean;
  /**
   * check if the string is a UUID (version 3, 4 or 5).
   */
  isUUID(str: string, version: number): boolean;
  /**
   * check if the string is uppercase.
   */
  isUppercase(str: string): boolean;
  /**
   * check if the string contains a mixture of full and half-width chars.
   */
  isVariableWidth(str: string): boolean;
  /**
   * checks characters if they appear in the whitelist.
   */
  isWhitelisted(str: string, chars: Array<string>): boolean;
  /**
   * check if string matches the pattern.<br/><br/>Either `matches('foo', /foo/i)` or `matches('foo', 'foo', 'i')`.
   */
  matches(str: string, pattern: string, modifier: string): boolean;
}

export const Validator: IValidator = validator;