# imports
# generic imports
import numpy as np
import re
import time
import pandas as pd
import matplotlib.pyplot as plt

# importing selenium related packages
import selenium
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import ElementClickInterceptedException

### GIANT
# giant_locations
def giant_locations(zipcodes, bad_zip = [22216, 22241, 22245], sleep_time = 2, driver_wait = 20):
    '''get shortened list of zipcodes and locations for Giant: shortened_zipcodes AND shortened_locations '''

    # Create Giant driver and go to website
    driver = webdriver.Chrome(ChromeDriverManager().install())
    driver.get("https://giantfood.com/")

    # close initial popup w X button
    x_button = driver.find_element_by_class_name("modal_close")
    x_button.click()

    # close second popup w X button
    wait = WebDriverWait(driver, driver_wait)
    x_button_2 = wait.until(EC.element_to_be_clickable((By.XPATH, '//button[@aria-label="close dialog"]')))
    x_button_2 = driver.find_element_by_xpath('//button[@aria-label="close dialog"]')
    x_button_2.click()

    # Change shopping mode to find stores
    change = driver.find_element_by_xpath('//button[@aria-label="Change shopping mode"]')
    change.click()

    # choose to enter a zip code
    enter_zip = wait.until(EC.element_to_be_clickable((By.XPATH, '//button[@class="button button--prime pdl-service-selector_btn"]')))
    enter_zip.click()

    # distances and locations lists
    distances = []; locations = []

    # zipcodes without stores for whatever reason but still listed as Arlington
    for zipcode in zipcodes:
        if(zipcode not in bad_zip):
            # enters new zipcode
            new_zip = wait.until(EC.element_to_be_clickable((By.ID, 'search-zip-code')))
            new_zip.clear()
            new_zip.send_keys(str(zipcode))

            # finds stores by zipcode
            find_stores = driver.find_element_by_id('search-location')
            find_stores.click()
            time.sleep(sleep_time)
            find_stores.click()
            time.sleep(sleep_time)

            # append distances and locations to lists
            distances.append(driver.find_element_by_xpath('//li//span[1]').text)
            locations.append(driver.find_element_by_xpath('//li//span[2]').text + ", " + driver.find_element_by_xpath('//li//span[3]').text)

    # close driver
    driver.quit()

    # getting zipcodes with different closest Giant
    _, idxs = np.unique(locations, return_index = True)
    shortened_zipcodes = zipcodes[idxs][1:] #dropping zipcodes with no closest GIANT -- Might change if some zipcodes are dropped
    shortened_locations = _[1:]
    return shortened_zipcodes, shortened_locations

# giant_driver function
def giant_driver(shortened_zipcodes, giant_foods, sleep_time = 2, driver_wait = 20, standard = True):
    '''
    description: 
    
    inputs:
    
    outputs:
    '''
    # loop over shortened list of zipcodes, collecting staples
    items_by_zip = []
    for i, zipcode in enumerate(shortened_zipcodes):
        # GIANT FOOD List: items_by_zip AND shortened_locations
        # create driver and go to driver website
        driver = webdriver.Chrome(ChromeDriverManager().install())
        driver.get("https://giantfood.com/")

        # close popups
        x_button = driver.find_element_by_class_name("modal_close")
        x_button.click()
        x_button_2 = driver.find_element_by_xpath('//button[@aria-label="close dialog"]')
        x_button_2.click()

        # change shopping mode
        wait = WebDriverWait(driver, driver_wait)
        change = driver.find_element_by_xpath('//button[@aria-label="Change shopping mode"]')
        change.click()

        # select option to enter zipcode
        enter_zip = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/div[1]/div[3]/aside/div/div/div/section/div/div/div[1]/div[1]/div[1]/div/div[3]/div/button')))
        enter_zip.click()

        # pass in new zipcode
        new_zip = wait.until(EC.element_to_be_clickable((By.ID, 'search-zip-code')))
        new_zip.clear()
        new_zip.send_keys(str(zipcode))

        # select store location (has to click 2x to go through)
        find_stores = driver.find_element_by_id('search-location')
        find_stores.click()
        time.sleep(sleep_time)
        find_stores.click()
        time.sleep(sleep_time)

        # go to the top store selected
        go_top_store = driver.find_element_by_xpath('/html/body/div[1]/div[3]/aside/div/div/div/section/div/div/div/div[2]/div[3]/ul/li[1]/div/div[3]/button')
        go_top_store.click()

        # loop over staplees
        items = []
        for food in giant_foods:
            # search for food
            time.sleep(sleep_time)
            search_bar = driver.find_element_by_id("typeahead-search-input")
            search_bar.clear()
            search_bar.send_keys(food)

            # select that food item
            enter_food = driver.find_element_by_xpath('//button[@class="button search-button button--prime"]')
            enter_food.click()
            if standard:
                if (food == giant_foods[1]) or (food == giant_foods[2]) or (food == giant_foods[6]) or (food == giant_foods[7]):
                    time.sleep(sleep_time)
                    best_match = driver.find_element_by_xpath('/html/body/div[1]/div[4]/div/div/div/div/div[2]/div[1]/div/div[2]/div/div/div/div[1]/div/div[2]/div[2]/div')
                    best_match.click()
                    option = driver.find_element_by_xpath('/html/body/div[1]/div[4]/div/div/div/div/div[2]/div[1]/div/div[2]/div/div/div/div[1]/div/div[2]/div[2]/div/div/select/option[3]')
                    option.click()

            # obtain price and name
            time.sleep(sleep_time)
            element = wait.until(EC.element_to_be_clickable((By.CLASS_NAME, 'product-tile_content')))
            items.append(element.text)

        # remove add to cart and append to list
        items = np.array([item.replace('\nAdd to Cart', '') for item in items])
        items_by_zip.append(items)
        
        # close driver
        driver.quit()
        
    items_by_zip = np.array(items_by_zip)
    return items_by_zip

# Gets GIANT prices, products, and other information
def giant_price_item_other(items_by_zip):
    if_sale_giant = np.array([np.array([1 if items_by_zip[j][i][:4] == "SALE" else 0 for i in range(len(items_by_zip[j]))]) for j in range(len(items_by_zip))])
    no_sale_giant = np.array([np.array([items_by_zip[j][i].split("SALE\n")[-1] for i in range(len(items_by_zip[j]))])  for j in range(len(items_by_zip))])
    prices_giant = np.array([np.array([float(no_sale_giant[j][i].split("\n")[0].replace("$", "")) for i in range(len(no_sale_giant[j]))]) for j in range(len(no_sale_giant))])

    cleaned_giant = np.array([np.array(["\n".join(no_sale_giant[j][i].split("\n")[:1] + no_sale_giant[j][i].split("\n")[2:]) if if_sale_giant[j][i] == 1
                        else no_sale_giant[j][i] for i in range(len(no_sale_giant[j]))]) for j in range(len(no_sale_giant))])

    cleaned_items_giant = np.array([np.array([cleaned_giant[j][i].split("\n")[1] for i in range(len(cleaned_giant[j]))]) for j in range(len(cleaned_giant))])
    other_info_giant = np.array([np.array([cleaned_giant[j][i].split("\n")[2] if len(cleaned_giant[j][i].split("\n")) > 2 else "" for i in range(len(cleaned_giant[j]))]) for j in range(len(cleaned_giant))])

    return prices_giant, cleaned_items_giant, other_info_giant
    # LOOKS GOOD
    
# convert pricing and food information into a dataframe
def make_df(prices, items, other, locations, store):
    a = np.array([item for sublist in items for item in sublist])
    b = np.array([item for sublist in prices for item in sublist])
    c = np.array([item for sublist in other for item in sublist])
    d = np.array([locations[i] for i in range(len(locations)) for j in range(len(items[0]))])
    e = np.array([store for i in range(len(locations)) for j in range(len(items[0]))])

    df = pd.DataFrame({"Item": a, "Price": b, "Other_Info": c, "Location": d, "Store": e})
    return df

# from scratch function from foods to dataframe: giant
def giant(foods, zipcodes, standard = True):
    shortened_zipcodes, shortened_locations = giant_locations(zipcodes)
    items_by_zip = giant_driver(shortened_zipcodes, foods, standard = standard)
    prices_giant, cleaned_items_giant, other_info_giant = giant_price_item_other(items_by_zip)
    df = make_df(prices_giant, cleaned_items_giant, other_info_giant, shortened_locations, "Giant")
    return df

### HARRIS TEETER
# ht_locations
def ht_locations(zipcodes, sleep_time = 2, driver_wait = 20):
    # sleep and wait times

    # create Harris Teeter driver, maximizing window
    ht_driver = webdriver.Chrome(ChromeDriverManager().install())
    ht_driver.maximize_window()

    # create empty lists for store locations and distances
    info = []; ht_distance = []

    # loop over each zipcode in Arlington and find the top store - remove any duplicates
    for j, zipcode in enumerate(zipcodes):
        # visit Harris Teeter website
        ht_driver.get("https://www.harristeeter.com/order-online/expresslane-groceries")

        # enter zip code
        wait = WebDriverWait(ht_driver, driver_wait)
        enter_zip = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/div[1]/div/app-root/app-groceries/section/div[1]/div/div/div[2]/pickup-text-component/div/form/div/mat-form-field/div/div[1]/div/input')))
        enter_zip.send_keys(str(zipcode))

        # send zip code
        submit_zip = wait.until(EC.element_to_be_clickable((By.CLASS_NAME, 'btn')))
        submit_zip.click()

        # Close "cannot determine location" message (might be specific to my computer)
        skip_loc_set = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/div[3]/div[2]/div/mat-dialog-container/material-confirm-prompt/div/div[2]/button')))
        skip_loc_set.click()

        # extract store location information
        element = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/div[1]/div/app-root/order-online-groceries-store-locator/div/store-locator-component/section/div[1]/div/div[1]/div[1]/div[2]/div/div[1]/div[1]/p')))
        info.append(element.text)

        # extract distance information
        element = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/div[1]/div/app-root/order-online-groceries-store-locator/div/store-locator-component/section/div[1]/div/div[1]/div[1]/div[2]/div/div[1]/div[2]/span')))
        ht_distance.append(element.text)

    # close driver
    ht_driver.quit()

    # remove any duplicates
    unique_info, ht_idxs = np.unique(info, return_index = True)
    ht_zipcodes = zipcodes[ht_idxs]
    unique_ht_distance = np.array(ht_distance)[ht_idxs]
    return ht_zipcodes, unique_info

# ht_driver
def ht_driver(ht_zipcodes, ht_foods, sleep_time = 2, driver_wait = 20, standard = True):
    # GET Harris Teeter FOOD INFORMATION: ht_items_by_zip
    # sleep and wait times

    # create Harris Teeter Driver with maximized window, create empty list of items to be built out for each store
    ht_driver = webdriver.Chrome(ChromeDriverManager().install())
    ht_driver.maximize_window()

    # loop over zipcodes
    ht_items_by_zip = [] 
    for zipcode in ht_zipcodes:
        # visit Harris Teeter website
        ht_driver.get("https://www.harristeeter.com/order-online/expresslane-groceries")

        if zipcode == ht_zipcodes[0]:
            wait = WebDriverWait(ht_driver, driver_wait)
            accept_cookies = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/div[1]/div/footer/div[4]/div[2]/div/button')))
            accept_cookies.click()

        # enter zipcodes
        wait = WebDriverWait(ht_driver, driver_wait)
        enter_zip = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/div[1]/div/app-root/app-groceries/section/div[1]/div/div/div[2]/pickup-text-component/div/form/div/mat-form-field/div/div[1]/div/input')))
        enter_zip.send_keys(str(zipcode))

        # submit zipcode
        submit_zip = wait.until(EC.element_to_be_clickable((By.CLASS_NAME, 'btn')))
        submit_zip.click()

        # Close "cannot determine location" message (might be specific to my computer)
        skip_loc_set = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/div[3]/div[2]/div/mat-dialog-container/material-confirm-prompt/div/div[2]/button')))
        skip_loc_set.click()

        # go to the top store (the unique store associated with that zipcode)
        go_top_store = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/div[1]/div/app-root/order-online-groceries-store-locator/div/store-locator-component/section/div[1]/div/div[1]/div[1]/div[2]/div/div[1]/div[2]/a[2]')))
        go_top_store.send_keys("\n")

        # loop over staples and store information in list
        ht_items = []
        for food in ht_foods:
            # select search bar and enter staple
            time.sleep(sleep_time)
            search_bar = ht_driver.find_element_by_id("searchStr-mobile")
            search_bar.clear()
            search_bar.send_keys(food)

            # search
            enter_food = ht_driver.find_element_by_xpath('//hts-search-product/div/button')
            enter_food.click()

            if standard:
                if food == ht_foods[0]:
                    time.sleep(sleep_time)
                    drop_down = ht_driver.find_element_by_id("dropdownMenuButton")
                    drop_down.click()
                    unit_price = ht_driver.find_element_by_xpath("/html/body/app-root/div/hts-layout/span/hts-search/div/section/div/div[2]/div[1]/div[2]/div[1]/div/div/a[4]")
                    unit_price.click()

                if (food == ht_foods[1]) or (food == ht_foods[11]) or (food == ht_foods[12]):
                    if zipcode != ht_zipcodes[5]:
                        time.sleep(sleep_time)
                        drop_down = ht_driver.find_element_by_id("dropdownMenuButton")
                        drop_down.click()
                        price = ht_driver.find_element_by_xpath("/html/body/app-root/div/hts-layout/span/hts-search/div/section/div/div[2]/div[1]/div[2]/div[1]/div/div/a[3]")
                        price.click()

                # FIX THIS!!!
                if (food == ht_foods[-2]) and (zipcode == ht_zipcodes[2]):
                    time.sleep(sleep_time)
                    element = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/app-root/div/hts-layout/span/hts-search/div/section/div/div[2]/div[2]/ul/hts-product-info[2]/li/span/a[2]/span[2]')))
                    ht_items.append(element.text)
                    # 2 or 3 for info???

                else:
                    # extract information on food item and add to list
                    time.sleep(sleep_time)
                    element = wait.until(EC.element_to_be_clickable((By.CLASS_NAME, 'forlist-view')))
                    ht_items.append(element.text)

            else:
                # extract information on food item and add to list
                time.sleep(sleep_time)
                element = wait.until(EC.element_to_be_clickable((By.CLASS_NAME, 'forlist-view')))
                ht_items.append(element.text)
                
        ht_items_by_zip.append(ht_items)

    # close driver
    ht_driver.quit()

    # convert from list to array
    ht_items_by_zip = np.array(ht_items_by_zip)
    return ht_items_by_zip

# ht_price_item_other
def ht_price_item_other(ht_items_by_zip):
    cleaned_items_ht = np.array([np.array([ht_items_by_zip[j][i].split("\n")[0] for i in range(len(ht_items_by_zip[j]))]) for j in range(len(ht_items_by_zip))])
    prices_ht = np.array([np.array([float(ht_items_by_zip[j][i].split("\n")[2].split(" ")[0].replace("$", "").replace("/lb", "")) for i in range(len(ht_items_by_zip[j]))]) for j in range(len(ht_items_by_zip))])
    other_info_ht = np.array([np.array([ht_items_by_zip[j][i].split("\n")[1] for i in range(len(ht_items_by_zip[j]))]) for j in range(len(ht_items_by_zip))])
    return prices_ht, cleaned_items_ht, other_info_ht

# ht
def ht(foods, zipcodes, standard = True):
    shortened_zipcodes, shortened_locations = ht_locations(zipcodes)
    items_by_zip = ht_driver(shortened_zipcodes, ht_foods = foods, standard = standard)
    prices_ht, cleaned_items_ht, other_info_ht = ht_price_item_other(items_by_zip)
    df = make_df(prices_ht, cleaned_items_ht, other_info_ht, shortened_locations, "Harris Teeter")
    return df

### SAFEWAY
# sw_locations
def sw_locations(zipcodes, sleep_time = 2, driver_wait = 20):
    # gets zipcodes with a unique closest Safeway: unique_sw_locations

    # create Safeway driver and maximize window
    sw_driver = webdriver.Chrome(ChromeDriverManager().install())
    sw_driver.get("https://www.safeway.com/")
    sw_driver.maximize_window()

    # click to change zipcode
    wait = WebDriverWait(sw_driver, driver_wait)
    change_zip = wait.until(EC.element_to_be_clickable((By.ID, 'openFulfillmentModalButton')))
    change_zip.click()

    # loop over zipcodes
    sw_info = []
    sw_distance = []
    for j, zipcode in enumerate(zipcodes):
        # enter zipcode and submit
        wait = WebDriverWait(sw_driver, driver_wait)
        enter_zip = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/div[2]/div/div/div[3]/div/div/div/div/div[2]/store-fulfillment-modal-unified/div/div/div/div[2]/store-fulfillment-tabs/div/div[1]/input')))
        enter_zip.clear()
        time.sleep(sleep_time)
        enter_zip.send_keys(str(zipcode), '\n')

        # extract location information on Safeway
        time.sleep(sleep_time)
        element = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/div[2]/div/div/div[3]/div/div/div/div/div[2]/store-fulfillment-modal-unified/div/div/div/div[2]/store-fulfillment-tabs/div/div[2]/div/div[1]/div/div/div[1]//div[1]')))
        sw_info.append(element.text)

        # extract distance information on Safeway
        element = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/div[2]/div/div/div[3]/div/div/div/div/div[2]/store-fulfillment-modal-unified/div/div/div/div[2]/store-fulfillment-tabs/div/div[2]/div/div[1]/div/div/div[1]/store-card/div[2]/div/p')))
        sw_distance.append(element.text)

    # close driver
    sw_driver.quit()

    # extracts unique Safeway locations and zipcodes with unique safeways
    unique_sw_locations, sw_idx = np.unique(sw_info, return_index = True)
    sw_zipcodes = zipcodes[sw_idx]
    return sw_zipcodes, unique_sw_locations

# sw_driver
def sw_driver(sw_zipcodes, sw_foods, standard = True, sleep_time = 2, driver_wait = 20):
    # SAFEWAY LOCATIONS AND ITEMS: unique_sw_locations AND sw_items_by_zip
    # struggles on the last 2 unique Safeways in Arlington area - makes exception and work!

    # create Safeway driver and maximize window
    sw_driver = webdriver.Chrome(ChromeDriverManager().install())
    sw_driver.maximize_window()

    # loop over all of the zipcodes for which there is a unique closest safeway
    sw_items_by_zip = []
    for k, zipcode in enumerate(sw_zipcodes):
        # go to Saveway website
        sw_driver.get("https://www.safeway.com/")

        # go to change zipcode
        wait = WebDriverWait(sw_driver, driver_wait)
        change_zip = wait.until(EC.element_to_be_clickable((By.ID, 'openFulfillmentModalButton')))
        change_zip.click()

        # change the zipcode
        enter_zip = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/div[2]/div/div/div[3]/div/div/div/div/div[2]/store-fulfillment-modal-unified/div/div/div/div[2]/store-fulfillment-tabs/div/div[1]/input')))
        enter_zip.clear()
        time.sleep(sleep_time)
        enter_zip.send_keys(str(zipcode), '\n')

        # go to the top store for that zipcode (exception for last two stores - not sure why this is an issue)
        time.sleep(sleep_time)
        if k < 6:
            go_top_store = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/div[2]/div/div/div[3]/div/div/div/div/div[2]/store-fulfillment-modal-unified/div/div/div/div[2]/store-fulfillment-tabs/div/div[2]/div/div[1]/div/div/div[1]/store-card/div[2]/div/a')))
            go_top_store.click()
        else:
            # select #2 store
            go_top_store = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/div[2]/div/div/div[3]/div/div/div/div/div[2]/store-fulfillment-modal-unified/div/div/div/div[2]/store-fulfillment-tabs/div/div[2]/div/div[1]/div/div/div[2]/store-card/div[2]/div/a')))
            go_top_store.click()

        # loop over all the staple items
        sw_items = []
        time.sleep(sleep_time)
        for food in sw_foods:
            # search for food
            time.sleep(sleep_time)
            search_bar = sw_driver.find_element_by_id("skip-main-content")
            search_bar.clear()
            search_bar.send_keys(food, "\n")

            if standard:
                if (food == sw_foods[2]) or (food == sw_foods[3]) or (food == sw_foods[-4]):
                    time.sleep(sleep_time)
                    sort = wait.until(EC.element_to_be_clickable((By.XPATH, "//sort-by/div/div/button")))
                    sort.click()
                    price = wait.until(EC.element_to_be_clickable((By.XPATH, "//search-sort/sort-by/div/div/ul/li[2]/a")))
                    price.click()

            # extract information on staple and append to list
            time.sleep(sleep_time)
            element = wait.until(EC.element_to_be_clickable((By.CLASS_NAME, 'container')))
            sw_items.append(element.text)
        sw_items_by_zip.append(sw_items)

    # close driver
    sw_driver.quit()

    sw_items_by_zip = np.array(sw_items_by_zip)
    return sw_items_by_zip

# sw_price_item_other
def sw_price_item_other(sw_items_by_zip):
    cleaned_safeway = np.array([np.array([sw_items_by_zip[j][i][19:] if sw_items_by_zip[j][i][0] == "a" else sw_items_by_zip[j][i][11:] for i in range(len(sw_items_by_zip[j]))]) for j in range(len(sw_items_by_zip))])

    cleaned_items_sw = np.array([np.array([cleaned_safeway[j][i].split("\n")[-2] for i in range(len(cleaned_safeway[j]))]) for j in range(len(cleaned_safeway))])
    prices_sw = np.array([np.array([float(cleaned_safeway[j][i].split("\n")[0].split(" ")[0].replace("$", "")) for i in range(len(cleaned_safeway[j]))]) for j in range(len(cleaned_safeway))])
    other_info_sw = np.array([np.array([cleaned_safeway[j][i].split("\n")[-1] for i in range(len(cleaned_safeway[j]))]) for j in range(len(cleaned_safeway))])
    return prices_sw, cleaned_items_sw, other_info_sw

# sw
def sw(foods, zipcodes, standard = True):
    shortened_zipcodes, shortened_locations = sw_locations(zipcodes)
    items_by_zip = sw_driver(shortened_zipcodes, sw_foods = foods, standard = standard)
    prices_sw, cleaned_items_sw, other_info_sw = sw_price_item_other(items_by_zip)
    df = make_df(prices_sw, cleaned_items_sw, other_info_sw, shortened_locations, "Safeway")
    return df

### ALDI
def aldi_locations(zipcodes, sleep_time = 2, driver_wait = 20):
    # GET ALDI STORE LOCATIONS: unique_aldi_locs

    # Create ALDI driver and visit website
    aldi_driver = webdriver.Chrome(ChromeDriverManager().install())
    aldi_driver.get("https://shop.aldi.us/store/aldi/storefront/?utm_source=aldi_outlink&utm_medium=google.com|none|search|none")

    # click on pickup option to locate stores
    wait = WebDriverWait(aldi_driver, driver_wait)
    click_pickup = wait.until(EC.element_to_be_clickable((By.ID, 'service-type-button-pickup')))
    click_pickup.click()

    # create empty list for ALDI locations and loop over zipcodes
    aldi_locs = []
    for i, zipcode in enumerate(zipcodes):
        # if starting the loop then take an additional step send a single space (not sure why a response is needed before removing the zipcode placeholder)
        if i == 0:
            send_zip = wait.until(EC.element_to_be_clickable((By.ID, 'locationInput')))
            send_zip.send_keys(" ")

        # send zipcode and hit enter
        send_zip = wait.until(EC.element_to_be_clickable((By.ID, 'locationInput')))
        send_zip.clear()
        send_zip.send_keys(str(zipcode), "\n")

        # record ALDI locations
        time.sleep(sleep_time)
        element = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/div[1]/div/header/div/div/div[7]/div[2]/div/div/div[1]/div[4]/button[1]/div[2]')))
        aldi_locs.append(element.text)
        time.sleep(sleep_time)

    # close driver
    aldi_driver.quit()

    # get unique locations and corresponding zipcodes
    unique_aldi_locs, aldi_idx = np.unique(np.array([aldi_locs[:-1][i].split('\n')[0] for i in range(len(aldi_locs) - 1)]), return_index = True)
    aldi_zipcodes = zipcodes[aldi_idx]
    return aldi_zipcodes, unique_aldi_locs

def aldi_driver(aldi_zipcodes, aldi_foods, sleep_time = 2, driver_wait = 20, standard = True):
    # GET ALDIs items for each store: aldi_items_by_zip

    # loop over all ALDI's zipcodes with unique stores (goal: find all ALDIs in reasonable distance from Arlington)
    aldi_items_by_zip = []
    for k, zipcode in enumerate(aldi_zipcodes):
        # create driver and go to website
        aldi_driver = webdriver.Chrome(ChromeDriverManager().install())
        aldi_driver.get("https://shop.aldi.us/store/aldi/storefront/?utm_source=aldi_outlink&utm_medium=google.com|none|search|none")

        # clicks the pickip option which allows you to select stores
        wait = WebDriverWait(aldi_driver, driver_wait)
        click_pickup = wait.until(EC.element_to_be_clickable((By.ID, 'service-type-button-pickup')))
        click_pickup.click()

        # deletes then sends zipcode (2x) - wasn't functional when only 1x
        for m in range(2):
            send_zip = wait.until(EC.element_to_be_clickable((By.ID, 'locationInput')))
            send_zip.clear()
            send_zip.send_keys(str(zipcode), "\n")
            send_zip.send_keys("\n")

        # go to the top store for that zipcode
        time.sleep(sleep_time)
        go_top_store = wait.until(EC.element_to_be_clickable((By.XPATH, "/html/body/div[1]/div/header/div/div/div[7]/div[2]/div/div/div[1]/div[4]/button[1]")))
        go_top_store.click()

        # start looping other staple items after sleep
        time.sleep(sleep_time)
        aldi_items = []
        for n, food in enumerate(aldi_foods):
            # send driver to search for food item - had to do this a bit differently due to some complications
            aldi_driver.get('https://shop.aldi.us/store/aldi/search_v3/{}'.format(food))
            
            if standard:
                if (n == 1):
                    time.sleep(sleep_time)
                    drop_down_brands = aldi_driver.find_element_by_xpath("/html/body/div[1]/div/div/div/div/div/div/div[1]/div/div/div[1]/div[1]/div[2]/button")
                    drop_down_brands.click()
                    goldhen = aldi_driver.find_element_by_id("231184")
                    goldhen.click()
                    apply = aldi_driver.find_element_by_xpath("/html/body/div[1]/div/div/div/div/div/div/div[1]/div/div/div[1]/div[1]/div[2]/div/div[2]/button[2]")
                    apply.click()
                    sort_by = aldi_driver.find_element_by_xpath("/html/body/div[1]/div/div/div/div/div/div/div[1]/div/div/div[1]/div[2]/button")
                    sort_by.click()
                    price = aldi_driver.find_element_by_xpath("/html/body/div[1]/div/div/div/div/div/div/div[1]/div/div/div[1]/div[2]/div/button[2]")
                    price.click()

            # select top food item under that search
            time.sleep(sleep_time)
            pic = wait.until(EC.element_to_be_clickable((By.XPATH, '//a[@class="css-er4k5d"]')))
            pic.click()

            # extract information on that food item
            time.sleep(2*sleep_time)
            element = wait.until(EC.element_to_be_clickable((By.XPATH, '//div[@class="col-md-5 itemModalHeader"]/div')))
            aldi_items.append(element.text)

            # close out of popup for that item - returning to search results
            close = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/div[5]/div/div/div/div[2]/div/div/div/div/div/div/div[1]/button')))
            close.click()

        # add all items from a store to list and close driver
        aldi_items_by_zip.append(aldi_items)
        aldi_driver.quit()

    aldi_items_by_zip = np.array(aldi_items_by_zip)
    return aldi_items_by_zip

def aldi_price_item_other(aldi_items_by_zip):
    cleaned_aldi = np.array([np.array([aldi_items_by_zip[j][i].replace("\nFREE PICKUP", "").replace("\nCurrent price:", "") for i in range(len(aldi_items_by_zip[j]))]) for j in range(len(aldi_items_by_zip))])

    for i in range(len(cleaned_aldi) - 1):
        for j in range(len(cleaned_aldi[0])):
            if (len(cleaned_aldi[i + 1][j].split('\n')) == 1):
                cleaned_aldi[i + 1][j] = cleaned_aldi[0][j]

    cleaned_items_aldi = np.array([np.array([cleaned_aldi[j][i].split("\n")[0] for i in range(len(cleaned_aldi[j]))]) for j in range(len(cleaned_aldi))])
    prices_aldi = np.array([np.array([float(cleaned_aldi[j][i].split("\n")[2].split("$")[1].split(" ")[0]) for i in range(len(cleaned_aldi[j]))]) for j in range(len(cleaned_aldi))])
    other_info_aldi = np.array([np.array([cleaned_aldi[j][i].split("\n")[1] for i in range(len(cleaned_aldi[j]))]) for j in range(len(cleaned_aldi))])
    return prices_aldi, cleaned_items_aldi, other_info_aldi

# aldi
def aldi(foods, zipcodes, standard = True):
    shortened_zipcodes, shortened_locations = aldi_locations(zipcodes)
    items_by_zip = aldi_driver(shortened_zipcodes, aldi_foods = foods, standard = standard)
    prices_aldi, cleaned_items_aldi, other_info_aldi = aldi_price_item_other(items_by_zip)
    df = make_df(prices_aldi, cleaned_items_aldi, other_info_aldi, shortened_locations, "Aldi")
    return df

### TARGET
def target_locations(zipcodes, sleep_time = 2, driver_wait = 20):
    # COLLECT TARGET LOCATION INFORMATION: unique_target_locs

    # Create Target driver and visit website
    target_driver = webdriver.Chrome(ChromeDriverManager().install())
    target_driver.get("https://www.target.com/c/grocery/-/N-5xt1a")

    # select store option to begin passing in zipcodes
    wait = WebDriverWait(target_driver, driver_wait)
    store = wait.until(EC.element_to_be_clickable((By.ID, 'storeId-utilityNavBtn')))
    store.click()

    # loop over zipcodes to collect information on store location
    target_info = []
    for zipcode in zipcodes:
        # click on option to edit zipcode
        edit = wait.until(EC.element_to_be_clickable((By.ID, 'zipOrCityState')))
        edit.click()

        # delete zipcode then send new zipcode (not sure why enter_zip.clear() did not work)
        enter_zip = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/div[9]/div/div/div/div/div[1]/div/div[3]/div[1]/div/input')))
        enter_zip.send_keys('\b\b\b\b\b')
        enter_zip.send_keys(str(zipcode), "\n")

        # extract store location information
        element = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/div[9]/div/div/div/div/div[3]')))
        target_info.append(element.text)

    # close driver
    target_driver.quit()

    # get unique locations and corresponding zipcodes
    unique_target_locs, target_idx = np.unique(target_info, return_index = True)
    target_zipcodes = zipcodes[target_idx]
    return target_zipcodes, unique_target_locs

def target_driver(target_zipcodes, target_foods, sleep_time = 2, driver_wait = 20, standard = True):
    # I chose 80/20 although I could have selected 73/
    # Not sure if this matters but you get different amounts of bagel (20 oz vs 17 oz)
    # GET TARGET items: target_items_by_zip

    # start driver and visit Target side
    target_driver = webdriver.Chrome(ChromeDriverManager().install())
    target_driver.get("https://www.target.com/c/grocery/-/N-5xt1a")

    # loop over all unique Targets
    target_items_by_zip = []
    for k, zipcode in enumerate(target_zipcodes):
        # click on option to select a store
        wait = WebDriverWait(target_driver, driver_wait)
        store = wait.until(EC.element_to_be_clickable((By.ID, 'storeId-utilityNavBtn')))
        store.click()

        # edit and then add zipcode
        edit = wait.until(EC.element_to_be_clickable((By.ID, 'zipOrCityState')))
        edit.click()

        # erase old zipcode and send new one
        enter_zip = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/div[9]/div/div/div/div/div[1]/div/div[3]/div[1]/div/input')))
        enter_zip.send_keys('\b\b\b\b\b')
        enter_zip.send_keys(str(zipcode), "\n")

        # select the top store
        go_top_store = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/div[9]/div/div/div/div/div[3]/div[2]/div[1]/button')))
        go_top_store.click()

        # loop over staples at store
        targ_info = []
        for food in target_foods:
            # search for food item
            if (food == "Ground Beef 1lb 80") and (k == 4):
                food = "Ground Beef 1lb 73"

            target_driver.get("https://www.target.com/s?searchTerm={}".format(food))

            # extract slightly cleaned pricing info
            info = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/div[1]/div/div[4]/div[4]/div[2]/div/div[2]/div[3]/div/ul/li[1]/div/div[2]/div/div/div')))
            cleaned_info = "".join(re.split('(.\d\d)', info.text)[:-1])
            targ_info.append(cleaned_info)

        # append list of items to list and close driver
        target_items_by_zip.append(targ_info)
    target_driver.quit()

    target_items_by_zip = np.array(target_items_by_zip)
    return target_items_by_zip

def target_price_item_other(target_items_by_zip):
    cleaned_target = np.array([np.array([target_items_by_zip[j][i] for i in range(len(target_items_by_zip[j]))]) for j in range(len(target_items_by_zip))])

    cleaned_items_target = np.array([np.array([cleaned_target[j][i].split("\n")[0] for i in range(len(cleaned_target[j]))]) for j in range(len(cleaned_target))])
    prices_target = np.array([np.array([float(cleaned_target[j][i].split("\n")[-3].split(" ")[0].replace("$", "")) if cleaned_target[j][i].split("\n")[-1][:4] == "Free" else float(cleaned_target[j][i].split("\n")[-2].split(" ")[0].replace("$", "")) if cleaned_target[j][i].split("\n")[-1][:3] == "Buy" else float(cleaned_target[j][i].split("\n")[-1].split(" ")[0].replace("$", "")) for i in range(len(cleaned_target[j]))]) for j in range(len(cleaned_target))])
    other_info_target = np.array([np.array(["" for i in range(len(cleaned_target[j]))]) for j in range(len(cleaned_target))])
    return prices_target, cleaned_items_target, other_info_target

# target
def target(foods, zipcodes, standard = True):
    shortened_zipcodes, shortened_locations = target_locations(zipcodes)
    items_by_zip = target_driver(shortened_zipcodes, target_foods = foods, standard = standard)
    prices_target, cleaned_items_target, other_info_target = target_price_item_other(items_by_zip)
    df = make_df(prices_target, cleaned_items_target, other_info_target, shortened_locations, "Target")
    return df

### WHOLE FOODS MARKET
def wfm_locations(zipcodes, sleep_time = 2, driver_wait = 20):
    # CODE BELOW TO OBTAIN Whole Foods STORES: unique_wfm_locs

    # starts driver and maximizes window
    wfm_driver = webdriver.Chrome(ChromeDriverManager().install())
    wfm_driver.maximize_window()

    # loops over all Arlington zipcodes to find local WFMs
    wfm_locations = []
    for zipcode in zipcodes:
        # goes to WFM site (this approach works although it isn't the most efficient - shouldn't need to revisit site)
        wfm_driver.get("https://www.wholefoodsmarket.com/stores")

        # select option to browse products to select store
        wait = WebDriverWait(wfm_driver, driver_wait)
        browse_pdts = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/main/header/div/header/nav/div[3]/ul/li[1]/a')))
        browse_pdts.click()

        # send zipcode to get to top stores
        send_zip = wait.until(EC.element_to_be_clickable((By.ID, 'pie-store-finder-modal-search-field')))
        send_zip.send_keys(str(zipcode))

        # extract information on closest store to that zipcode
        go_top_store = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/div/main/div[2]/div[4]/div/div/div/section/div/wfm-search-bar/div[2]/div/ul/li[1]')))
        wfm_locations.append(go_top_store.text)

    # close driver
    wfm_driver.quit()

    # identify all unique locations (removing zipcodes corresponding to: "no stores found")
    unique_wfm_locs, wfm_idx = np.unique(wfm_locations, return_index = True)
    wfm_zipcodes = zipcodes[wfm_idx][[0, 2, 3]] # 1 = No stores found...
    return wfm_zipcodes, unique_wfm_locs[[0, 2, 3]]

def wfm_driver(wfm_zipcodes, wfm_foods, sleep_time = 2, driver_wait = 20, standard = True):
    # For Whole Foods ITEMS: wfm_items_by_zip

    # collect items for stores
    wfm_items_by_zip = []

    # loop over important zipcodes - these zipcodes correspond to unique stores
    for ii, zipcode in enumerate(wfm_zipcodes):
        # start up driver and visit WFM, maximizng window
        wfm_driver = webdriver.Chrome(ChromeDriverManager().install())
        wfm_driver.get("https://www.wholefoodsmarket.com/stores")
        wfm_driver.maximize_window()

        # go to browse products
        wait = WebDriverWait(wfm_driver, driver_wait)
        browse_pdts = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/main/header/div/header/nav/div[3]/ul/li[1]/a')))
        browse_pdts.click()

        # send zipcode information
        send_zip = wait.until(EC.element_to_be_clickable((By.ID, 'pie-store-finder-modal-search-field')))
        send_zip.send_keys(str(zipcode))

        # go to the top store for that zipcode
        go_top_store = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/div/main/div[2]/div[4]/div/div/div/section/div/wfm-search-bar/div[2]/div/ul/li[1]')))
        go_top_store.click()

        # empty list to store information on food items for each iteration in loop below
        wfm_info = []

        # loop to search for all food items
        for food in wfm_foods:
            # search for food item
            search = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/div/main/header/nav/div[3]/div[1]/div/div/form/input')))
            search.send_keys(food, '\n')
            
            if standard:
                if (food == wfm_foods[1]) or (food == wfm_foods[12]):
                    time.sleep(sleep_time)
                    drop_down = wfm_driver.find_element_by_id("sort-dropdown-select")
                    drop_down.click()
                    price = wfm_driver.find_element_by_xpath("//select/option[2]")
                    price.click()

            # wait a bit then copy text on this food item, appending it to list
            time.sleep(sleep_time)
            element = wait.until(EC.element_to_be_clickable((By.CLASS_NAME, 'w-pie--product-tile__content')))
            wfm_info.append(element.text)

        # add items to the list and close driver
        wfm_items_by_zip.append(wfm_info)
        wfm_driver.quit()

    wfm_items_by_zip = np.array(wfm_items_by_zip)
    return wfm_items_by_zip

def wfm_price_item_other(wfm_items_by_zip):
    cleaned_wfm = np.array([np.array([wfm_items_by_zip[j][i] for i in range(len(wfm_items_by_zip[j]))]) for j in range(len(wfm_items_by_zip))])

    cleaned_items_wfm = np.array([np.array([cleaned_wfm[j][i].split("\n")[-2] for i in range(len(cleaned_wfm[j]))]) for j in range(len(cleaned_wfm))])

    temp = np.array([np.array([cleaned_wfm[j][i].split("\n")[-3].split("/")[0].replace("$", "").split("Regular")[1] if cleaned_wfm[j][i].split("\n")[-1][:5] == "Prime" else cleaned_wfm[j][i].split("\n")[-1].split("/")[0].replace("$", "") for i in range(len(cleaned_wfm[j]))]) for j in range(len(cleaned_wfm))])
    prices_wfm = np.array([np.array([int(temp[j][i].replace("¢", ""))/100 if temp[j][i][2] == "¢" else float(temp[j][i]) for i in range(len(temp[j]))]) for j in range(len(temp))])
    other_info_wfm = np.array([np.array(["" for i in range(len(cleaned_wfm[j]))]) for j in range(len(cleaned_wfm))])
    return prices_wfm, cleaned_items_wfm, other_info_wfm

# wfm
def wfm(foods, zipcodes, standard = True):
    shortened_zipcodes, shortened_locations = wfm_locations(zipcodes)
    items_by_zip = wfm_driver(shortened_zipcodes, wfm_foods = foods, standard = standard)
    prices_wfm, cleaned_items_wfm, other_info_wfm = wfm_price_item_other(items_by_zip)
    df = make_df(prices_wfm, cleaned_items_wfm, other_info_wfm, shortened_locations, "Whole Foods")
    return df


