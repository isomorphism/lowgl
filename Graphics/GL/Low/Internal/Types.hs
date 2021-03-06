{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE DeriveFoldable #-}
{-# LANGUAGE DeriveTraversable #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
module Graphics.GL.Low.Internal.Types (
    module Graphics.GL.Low.Internal.Types,
    module Graphics.GL.Low.Internal.GLEnum
    ) where

import Control.Applicative
import Control.Exception
import Data.Monoid
import Data.Foldable
import Data.Traversable
import Data.Data (Data, Typeable)
import Foreign.Storable (Storable)
import Data.Text (Text)

import Graphics.GL

import Graphics.GL.Low.Internal.GLEnum
import Graphics.GL.Low.Classes


newtype TextureUnit = TextureUnit { fromTextureUnit :: GLuint } 
    deriving (Eq, Ord, Read, Show, Num, Integral, Real, Enum, Storable)

newtype AttribIndex = AttribIndex { fromAttribIndex :: GLuint } 
    deriving (Eq, Ord, Read, Show, Num, Integral, Real, Enum, Storable)

newtype UniformIndex = UniformIndex { fromUniformIndex :: GLuint } 
    deriving (Eq, Ord, Read, Show, Num, Integral, Real, Enum, Storable)


newtype AttribLocation = AttribLocation { fromAttribLocation :: GLuint } 
    deriving (Eq, Ord, Show, Storable, Data, Typeable)

newtype UniformLocation = UniformLocation { fromUniformLocation :: GLuint } 
    deriving (Eq, Ord, Show, Storable, Data, Typeable)

-- | Handle to a shader program.
newtype Program = Program { fromProgram :: GLuint } 
    deriving (Eq, Ord, Show, Storable, Data, Typeable)

-- | Handle to a shader object.
newtype Shader = Shader { fromShader :: GLuint } 
    deriving (Eq, Ord, Show, Storable, Data, Typeable)


data ShaderVar l t = ShaderVar
    { varName     :: Text
    , varLocation :: l
    , varType     :: t
    , varSize     :: Int
    } deriving (Eq, Ord, Show, Data, Typeable)

type ShaderAttrib = ShaderVar AttribLocation GLAttribType
type ShaderUniform = ShaderVar UniformLocation GLUniformType

-- | Handle to a VBO.
newtype VBO = VBO { fromVBO :: GLuint } 
    deriving (Eq, Ord, Read, Show, Storable, Data, Typeable)

instance GLObject VBO where
  glObjectName (VBO n) = fromIntegral n
  glObject = VBO . fromIntegral

instance BufferObject VBO


-- | Handle to an element array buffer object.
newtype ElementArray = ElementArray { fromElementArray :: GLuint }
    deriving (Eq, Ord, Read, Show, Storable, Data, Typeable)

instance GLObject ElementArray where
  glObjectName (ElementArray n) = fromIntegral n
  glObject = ElementArray . fromIntegral

instance BufferObject ElementArray



-- | A framebuffer object is an alternative rendering destination. Once an FBO
-- is bound to framebuffer binding target, it is possible to attach images
-- (textures or RBOs) for color, depth, or stencil rendering.
newtype FBO = FBO { fromFBO :: GLuint }
    deriving (Eq, Ord, Read, Show, Storable, Data, Typeable)

instance Framebuffer FBO where
  framebufferName = glObjectName

instance GLObject FBO where
  glObjectName (FBO n) = fromIntegral n
  glObject = FBO . fromIntegral


-- | An RBO is a kind of image object used for rendering. The only thing
-- you can do with an RBO is attach it to an FBO.
newtype RBO a = RBO { unRBO :: GLuint } 
    deriving (Eq, Ord, Read, Show, Storable, Data, Typeable)

instance GLObject (RBO a) where
  glObjectName (RBO n) = fromIntegral n
  glObject = RBO . fromIntegral


-- | A 2D texture. A program can sample a texture if it has been bound to
-- the appropriate texture unit.
newtype Tex2D a = Tex2D { fromTex2D :: GLuint }
    deriving (Eq, Ord, Read, Show, Storable, Data, Typeable)

instance Texture (Tex2D a) where
    bindTexture = glBindTexture GL_TEXTURE_2D . glObjectName

instance GLObject (Tex2D a) where
  glObjectName (Tex2D n) = fromIntegral n
  glObject = Tex2D . fromIntegral


-- | A cubemap texture is just six 2D textures. A program can sample a cubemap
-- texture if it has been bound to the appropriate texture unit.
newtype CubeMap a = CubeMap { fromCubeMap :: GLuint }
    deriving (Eq, Ord, Read, Show, Storable, Data, Typeable)

instance Texture (CubeMap a) where
    bindTexture = glBindTexture GL_TEXTURE_CUBE_MAP . glObjectName

instance GLObject (CubeMap a) where
  glObjectName (CubeMap n) = fromIntegral n
  glObject = CubeMap . fromIntegral


-- | Handle to a VAO.
newtype VAO = VAO { fromVAO :: GLuint }
    deriving (Eq, Ord, Read, Show, Storable, Data, Typeable)

instance GLObject VAO where
  glObjectName (VAO n) = fromIntegral n
  glObject = VAO . fromIntegral


-- | Six values, one on each side.
data Cube a = Cube
  { cubeRight  :: a
  , cubeLeft   :: a
  , cubeTop    :: a
  , cubeBottom :: a
  , cubeFront  :: a
  , cubeBack   :: a }
    deriving (Show, Functor, Foldable, Traversable)

instance Applicative Cube where
  pure x = Cube x x x x x x
  (Cube f1 f2 f3 f4 f5 f6) <*> (Cube x1 x2 x3 x4 x5 x6) =
    Cube (f1 x1) (f2 x2) (f3 x3) (f4 x4) (f5 x5) (f6 x6)

instance Monoid a => Monoid (Cube a) where
  mempty = Cube mempty mempty mempty mempty mempty mempty
  (Cube x1 x2 x3 x4 x5 x6) `mappend` (Cube y1 y2 y3 y4 y5 y6) = Cube
    (x1 <> y1)
    (x2 <> y2)
    (x3 <> y3)
    (x4 <> y4)
    (x5 <> y5)
    (x6 <> y6)


data ShaderError = ShaderTypeError String
                 | ProgramError ProgramError
    deriving (Eq, Ord, Show, Data, Typeable)
  
instance Exception ShaderError

-- | The error message emitted by the driver when shader compilation or
-- linkage fails.
data ProgramError = ShaderError (Maybe ShaderType) String
                  | LinkError String
    deriving (Eq, Ord, Show, Data, Typeable)

pattern VertexShaderError s = ShaderError (Just VertexShader) s
pattern FragmentShaderError s = ShaderError (Just FragmentShader) s

instance Exception ProgramError


