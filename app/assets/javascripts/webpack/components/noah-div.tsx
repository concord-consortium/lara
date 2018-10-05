import * as React from 'react'
import * as DOM from 'react-dom'


// By making state a class we can define default values.
class NoahDivState { }
interface NoahDivProps {
  label: string;
 }


export class NoahDiv extends
  React.Component<NoahDivProps, NoahDivState> {

    render() {
      const inputStyle = {
        'display': 'flex',
        'flex-direction': 'row',
        'flex-wrap': 'wrap',
        'justify-content': 'space-around',
        'padding': '0.5em',
        'background-color': 'hsl(0,10%,90%)'
      };
      return(
        <div style={inputStyle}>
          <div> This is NOAHS BRAND NEW TAG </div>
          <div> {this.props.label} </div>
        </div>
      )
    }
  }

