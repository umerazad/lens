{-# LANGUAGE CPP #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
#ifdef TRUSTWORTHY
{-# LANGUAGE Trustworthy #-}
#endif
-----------------------------------------------------------------------------
-- |
-- Module      :  Data.Text.Lazy.Lens
-- Copyright   :  (C) 2012-2014 Edward Kmett
-- License     :  BSD-style (see the file LICENSE)
-- Maintainer  :  Edward Kmett <ekmett@gmail.com>
-- Stability   :  experimental
-- Portability :  non-portable
--
----------------------------------------------------------------------------
module Data.Text.Lazy.Lens
  ( packed, unpacked
  , text
  , builder
  , utf8
  ) where

import Control.Lens
import Data.ByteString.Lazy as ByteString
import Data.Text.Lazy as Text
import Data.Text.Lazy.Builder
import Data.Text.Lazy.Encoding

-- $setup
-- >>> :set -XOverloadedStrings

-- | This isomorphism can be used to 'pack' (or 'unpack') lazy 'Text'.
--
-- >>> "hello"^.packed -- :: Text
-- "hello"
--
-- @
-- 'pack' x ≡ x '^.' 'packed'
-- 'unpack' x ≡ x '^.' 'from' 'packed'
-- 'packed' ≡ 'from' 'unpacked'
-- @
packed :: Iso' String Text
packed = iso Text.pack Text.unpack
{-# INLINE packed #-}

-- | This isomorphism can be used to 'unpack' (or 'pack') lazy 'Text'.
--
-- >>> "hello"^.unpacked -- :: String
-- "hello"
--
-- @
-- 'pack' x ≡ x '^.' 'from' 'unpacked'
-- 'unpack' x ≡ x '^.' 'packed'
-- @
--
-- This 'Iso' is provided for notational convenience rather than out of great need, since
--
-- @
-- 'unpacked' ≡ 'from' 'packed'
-- @
unpacked :: Iso' Text String
unpacked = iso Text.unpack Text.pack
{-# INLINE unpacked #-}

-- | Convert between lazy 'Text' and 'Builder' .
--
-- @
-- 'fromLazyText' x ≡ x '^.' 'builder'
-- 'toLazyText' x ≡ x '^.' 'from' 'builder'
-- @
builder :: Iso' Text Builder
builder = iso fromLazyText toLazyText
{-# INLINE builder #-}

-- | Traverse the individual characters in a 'Text'.
--
-- >>> anyOf text (=='c') "chello"
-- True
--
-- @
-- 'text' = 'unpacked' . 'traversed'
-- @
--
-- When the type is unambiguous, you can also use the more general 'each'.
--
-- @
-- 'text' ≡ 'each'
-- @
--
-- Note that when just using this as a 'Setter', @'setting' 'Data.Text.Lazy.map'@
-- can be more efficient.
text :: IndexedTraversal' Int Text Char
text = unpacked . traversed
{-# INLINE text #-}

-- | Encode/Decode a lazy 'Text' to/from lazy 'ByteString', via UTF-8.
--
-- Note: This function does not decode lazily, as it must consume the entire
-- input before deciding whether or not it fails.
--
-- >>> ByteString.unpack (utf8 # "☃")
-- [226,152,131]
utf8 :: Prism' ByteString Text
utf8 = prism' encodeUtf8 (preview _Right . decodeUtf8')
{-# INLINE utf8 #-}
