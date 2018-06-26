import React from 'react';
import smallFlag from '../static/img/us_flag_small.png';
import printLogo from '../static/img/print-logo.png';

const Header = () => (
  <header className="site-header">
    <div className="masthead">
      <div className="disclaimer">
        <span className="disclaimer__right">
          An official website of the United States Government
          <img
            src={smallFlag}
            alt="US flag signifying that this is a United States Federal Government website"
          />
        </span>
      </div>
      <img src={printLogo} className="u-print-only" alt="FEC logo" />
      <a title="Home" href="/" rel="home" className="site-title">
        <span className="u-visually-hidden">
          Federal Election Commission | United States of America
        </span>
      </a>
    </div>
  </header>
);

export default Header;
