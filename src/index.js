'use strict';

import './index.html';
import './styles/ifyoucanthandleme.css';
import giphyLogo from './PoweredBy_200px-White_HorizText.png';
import Elm from './Main.elm';

const mountNode = document.getElementById('main');
const app = Elm.Main.embed(mountNode);

const giphyImgElt = document.getElementById('giphyLogo');
giphyImgElt.src = giphyLogo;
