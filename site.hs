--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}

import           Data.Monoid                    ( mappend )
import           Hakyll                         ( makeItem
                                                , loadAll
                                                , defaultConfiguration
                                                , copyFileCompiler
                                                , fromList
                                                , idRoute
                                                , setExtension
                                                , compile
                                                , create
                                                , match
                                                , route
                                                , hakyllWith
                                                , compressCssCompiler
                                                , relativizeUrls
                                                , pandocCompiler
                                                , constField
                                                , dateField
                                                , defaultContext
                                                , listField
                                                , loadAndApplyTemplate
                                                , templateCompiler
                                                , recentFirst
                                                , Configuration
                                                  ( destinationDirectory
                                                  )
                                                , Context
                                                )
import           Hakyll.Favicon                 ( faviconsField
                                                , faviconsRules )

--------------------------------------------------------------------------------

config :: Configuration
config = defaultConfiguration { destinationDirectory = "docs" }

main :: IO ()
main = hakyllWith config $ do
  -- faviconsRules "images/favicon.svg"
  
  match "images/*" $ do
    route idRoute
    compile copyFileCompiler

  match "css/*" $ do
    route idRoute
    compile compressCssCompiler

  match (fromList ["index.md", "contact.md", "cv.md", "gallery.md", "talks.md"]) $ do
    route $ setExtension "html"
    compile
      $   pandocCompiler
      >>= loadAndApplyTemplate "templates/default.html" iconCtx
      >>= relativizeUrls

  match "posts/*" $ do
    route $ setExtension "html"
    compile
      $   pandocCompiler
      >>= loadAndApplyTemplate "templates/post.html"    postCtx
      >>= loadAndApplyTemplate "templates/default.html" postCtx
      >>= relativizeUrls

  create ["archive.html"] $ do
    route idRoute
    compile $ do
      posts <- recentFirst =<< loadAll "posts/*"
      let archiveCtx =
            listField "posts" postCtx (return posts)
              `mappend` constField "title" "Archives"
              `mappend` iconCtx

      makeItem ""
        >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
        >>= loadAndApplyTemplate "templates/default.html" archiveCtx
        >>= relativizeUrls

  -- match "index.html" $ do
  --     route idRoute
  --     compile $ do
  --         posts <- recentFirst =<< loadAll "posts/*"
  --         let indexCtx =
  --                 listField "posts" postCtx (return posts) `mappend`
  --                 constField "title" "Home"                `mappend`
  --                 iconCtx

  --         getResourceBody
  --             >>= applyAsTemplate indexCtx
  --             >>= loadAndApplyTemplate "templates/default.html" indexCtx
  --             >>= relativizeUrls

  match "templates/*" $ compile templateCompiler

--------------------------------------------------------------------------------
iconCtx :: Context String
iconCtx = faviconsField `mappend` defaultContext

postCtx :: Context String
postCtx = dateField "date" "%B %e, %Y" `mappend` iconCtx

