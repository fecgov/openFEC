# """
# Used by test_swagger_index.py
# """

import pytest

from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException
from selenium.common.exceptions import TimeoutException


class swagger_index:

  # VARS
  URL = 'http://127.0.0.1:5000/developers/' # 'https://api.open.fec.gov/developers/'
  COUNT__EXPECTED_SECTIONS = 18
  SECONDS__PAGE_LOAD_DELAY = 10 # seconds

  # Locators
  SELECTOR__CANDIDATE_SECTION_ID = 'operations-tag-candidate'
  SELECTOR__FINAL_ELEMENT_ID = 'operations-tag-legal'
  SELECTOR__SECTIONS_CLASS = 'opblock-tag-section'

  # Initializer
  def __init__(self, browser):
    self.browser = browser

  # Interaction Methods
  def load(self):
    self.browser.get(self.URL)
    try:
        elem = WebDriverWait(self.browser, self.SECONDS__PAGE_LOAD_DELAY).until(
            EC.presence_of_element_located((By.ID, self.SELECTOR__FINAL_ELEMENT_ID))
        )
        return True
    finally:
        return False

  def all_sections_exist(self):
    elements = self.browser.find_elements_by_class_name(self.SELECTOR__SECTIONS_CLASS)
    return len(elements) == self.COUNT__EXPECTED_SECTIONS

  def last_element_as_expected(self):
    elem = self.browser.find_element_by_css_selector("#" + self.SELECTOR__FINAL_ELEMENT_ID)
    return elem
