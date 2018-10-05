import * as React from 'react'
import * as DOM from 'react-dom'
import {AspectRatioChooser} from './components/aspect_ratio_chooser'
import {NoahDiv} from "./components/noah-div"

(<any>window).RenderComponent = (component:any, props:any, dom:any,) => {
  DOM.render(React.createElement(component, props), dom);
}

const defineWindowGlobal = (key:string, value:any) => {
  (<any>window)[key] = value
}


defineWindowGlobal('AspectRatioChooser', AspectRatioChooser);
defineWindowGlobal('NoahDiv', NoahDiv);

