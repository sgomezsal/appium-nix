from typing import Any, Dict
from appium import webdriver
from appium.options.common import AppiumOptions
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC


def automation_settings():
    """
    Professional Appium example:
    - Launch Android Settings
    - Navigate to Network section
    - Demonstrate explicit wait usage
    """

    capabilities: Dict[str, Any] = {
        "platformName": "Android",
        "automationName": "uiautomator2",
        "deviceName": "AndroidDevice",
        "noReset": True,
        "locale": "US",
        "language": "en",
    }

    driver = webdriver.Remote(
        "http://localhost:4723",
        options=AppiumOptions().load_capabilities(capabilities),
    )

    wait = WebDriverWait(driver, 20)

    # Launch native Android Settings app (safe & universal)
    driver.activate_app("com.android.settings")

    # Wait for main Settings screen
    network_option = wait.until(
        EC.presence_of_element_located(
            (AppiumBy.ANDROID_UIAUTOMATOR,
             'new UiSelector().textContains("Network")')
        )
    )

    print("Network option detected:", network_option.text)

    # Example interaction
    network_option.click()

    # Wait for Wi-Fi menu (example of next screen validation)
    wait.until(
        EC.presence_of_element_located(
            (AppiumBy.ANDROID_UIAUTOMATOR,
             'new UiSelector().textContains("Wi")')
        )
    )

    print("Navigation successful")

    driver.quit()


if __name__ == "__main__":
    automation_settings()
