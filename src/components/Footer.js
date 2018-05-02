import React from 'react';
import seal from '../static/img/seal--inverse.svg';

const Footer = () => (
  <footer className="footer">
    <div className="container">
      <div className="seal">
        <img
          className="seal__img"
          width="140"
          height="140"
          src={seal}
          alt="Seal of the Federal Election Commission | United States of America"
        />
        <p className="address__title">Federal Election Commission</p>
      </div>

      <div className="address">
        <ul className="social-media">
          <li>
            <div className="i icon--twitter">
              <a href="https://twitter.com/fec">
                <span className="u-visually-hidden">
                  The FEC&apos;s Twitter page
                </span>
              </a>
            </div>
          </li>
          <li>
            <div className="i icon--youtube">
              <a href="https://www.youtube.com/user/FECTube">
                <span className="u-visually-hidden">
                  The FEC&apos;s YouTube page
                </span>
              </a>
            </div>
          </li>
        </ul>

        <p>
          1050 First Street, NE<br /> Washington, DC 20463
        </p>

        <a
          href="https://public.govdelivery.com/accounts/USFEC/subscriber/topics?qsp=CODE_RED"
          target="_blank"
          rel="noopener noreferrer"
        >
          <button className="button--standard button--envelope">
            Sign up for FECMail
          </button>
        </a>
      </div>
    </div>
  </footer>
);

export default Footer;
