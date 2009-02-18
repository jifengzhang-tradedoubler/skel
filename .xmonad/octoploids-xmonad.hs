import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Layout
import XMonad.Config (defaultConfig)
import XMonad.Layout.NoBorders
import XMonad.Layout.Gaps
import XMonad.Hooks.DynamicLog hiding (xmobar)
import XMonad.Actions.CycleWS
import Data.Bits
import qualified Data.Map as M
import XMonad.Util.Run (spawnPipe)
import System.IO (hPutStrLn)
import Graphics.X11

main :: IO ()
main = do
        xmproc <- spawnPipe "xmobar /home/kjell/.xmonad/xmobarrc"
        xmonad defaultConfig
         {
--	   manageHook = manageDocks <+> manageHook defaultConfig,
--	   layoutHook = avoidStruts  $  layoutHook defaultConfig,
	   logHook = dynamicLogWithPP $ xmobarPP {
	                                           ppOutput = hPutStrLn xmproc
						 , ppTitle = xmobarColor "green" "" . shorten 128
                                                 }
	 , normalBorderColor  = "#334455"
         , focusedBorderColor = "#ff9900"
         , terminal           = "xterm -fg gray -bg black -cr red -ls -sl 1024 -vb +sb -fn -misc-fixed-medium-r-semicondensed-*-13-120-75-75-c-60-iso8859-*"
         , modMask = mod4Mask
--         , logHook = dynamicLogWithPP defaultPP { ppTitle  = shorten 160
--                                                , ppLayout = (>> "")
--                                                , ppOutput = hPutStrLn xmobar }
         , layoutHook = gaps [(U,18)] (smartBorders (tiled ||| Full))
         , manageHook = composeAll [ className =? "fontforge" --> doFloat,
                                     className =? "MPlayer"   --> doFloat,
                                     className =? "Gimp"      --> doFloat,
				     className =? "sun-applet-Main" --> doFloat,
				     className =? "sun.applet.Main" --> doFloat,
				     className =? "Qgo" --> doFloat
				   ]
         , keys = \c -> mykeys c `M.union` keys defaultConfig c
         }
  where
     tiled   = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2 -- toRational (2/(1+sqrt(5)::Double)) -- golden

     -- Percent of screen to increment by when resizing panes
     delta   = 0.03

     mykeys (XConfig {XMonad.modMask = modm}) = M.fromList $
             [ ((controlMask .|. modm, xK_Right), nextWS)
             , ((controlMask .|. modm, xK_Left),  prevWS)
             , ((modm, xK_b     ), sendMessage $ ToggleGaps)
             , ((modm, xK_m     ), spawn "minefield")
             , ((modm, xK_f     ), spawn "firefox")
	     , ((modm, xK_q     ), broadcastMessage ReleaseResources >> restart "xmonad" True) -- %! Restart xmonad
	      ]
