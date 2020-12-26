    print("====================================")
    print("[INIT] Setting Variables...")

    extwallet = "bc1qe7lfanpd53gdkkxkuv5rfzdawl75uj7cthyr0f"

    basechance     = 58
    basebet        = balance * (8 / 10000)
    winmultiplier  = 0.95
    lossmultiplier = 2.7255
    bethigh        = true        
    startbalance   = balance
    sessionprofit  = 0

    profitmax  = basebet*100
    betceiling = basebet*100
    betfloor   = basebet/2.5


    nextbet     = basebet
    lastgoodbet = basebet
    chance      = basechance
    enablezz    = false      
    enablesrc   = true     
    reset       = false

    spincount = 0
    spinlimit = 50

    plummetthresh  = -3
    inplummet      = false
    inplumbank     = basebet
    plummultiplier = (winmultiplier/1.33)

    inrecover       = false
    inrecspin       = 0
    inrecmax        = 3
    inrecmultiplier = 1.5

    minbtcbet = 0.00000002

    print("Done...")
    print(" ")
    print("===== SUMMARY =====")
    print("Base Bet: "..printval(basebet).."  |  Currency: "..currency)
    print("External Wallet: "..extwallet)
    print("Chance: "..chance.." | Next Bet: "..printval(nextbet).." "..currency.." | Profit Thresh: "..printval(profitmax))
    print("Bet Ceiling: "..printval(betceiling).."  |  Bet Floor: "..printval(betfloor).."  |  Plummet Bank: "..printval(inplumbank))
    print("Win Multiplier: "..winmultiplier.."  |  Loss Multiplier: "..lossmultiplier)
    print("====================")


    function dobet()

    displaybetinfo()
    checkbetoutcome()
    recoverycheck()
    plummetcheck()
    checklimits()
    nextbetsummary()

    end


    ------------------------------------------------------
    ---------- DISPLAY BET INFORMATION TO CONSOLE --------
    ------------------------------------------------------

    function displaybetinfo()
        print("Ceiling: "..printval(betceiling).."  |  Floor: "..printval(betfloor).." | Profit Thresh: "..profitmax)
        print("Chance: "..chance.."  |  Base Chance: "..basechance)
        print("LGB: "..printval(lastgoodbet).."  |  Session Profit: "..printval(sessionprofit))
    end



    ------------------------------------------------------
    ----------------- DISPLAY NEXTBET INFO ---------------
    ------------------------------------------------------

    function nextbetsummary()

        -- Output what the next bet is going to be
        print("NEXT BET: "..printval(nextbet))
        print(" ")
        print(" ")
        print(" ")
        print(" ")

    end

    ------------------------------------------------------
    --------------- DETERMINE WIN / LOSS -----------------
    ------------------------------------------------------

    function checkbetoutcome()
    if (win == false) then        
            print("[LOSS]  Result Profit: "..currentprofit.."  |  Current Streak: "..currentstreak)
            nextbet = (previousbet*lossmultiplier)
            print("Multiplying Bet: "..lossmultiplier.."x")
            chance = chance*1.15
            if chance > 90 then
                chance = 90
            end
            print("Increasing Chance to: "..chance)
        elseif (win == true) then
            print("[WIN]  Result Profit: "..currentprofit.."  |  Current Streak: "..currentstreak)
            if (currentstreak == 1) then
            print("       Resuming Bet Amt: "..lastgoodbet)
                nextbet = lastgoodbet
            print("       Resetting Bet Chance: "..basechance)
                chance = basechance
            else
            lastgoodbet = previousbet
            nextbet = (previousbet*winmultiplier)
            print("Multiplying Bet: "..winmultiplier.."x")
            end
        end
    end


    ------------------------------------------------------
    ---------- BET LIMITATIONS / RESTRICTIONS ------------
    ------------------------------------------------------

    function checklimits()
        
        if (inrecover == false) then
            -- Update the basebet
                updatebasebet()
            
            -- Check if the bet ceiling has been hit --
            if nextbet > betceiling then
                print("Notice: Bet Ceiling Reached!")
                nextbet = betceiling
                print("Next bet set to: "..nextbet)
            end

            -- Check if the bet floor has been hit
            if nextbet < betfloor then
                print("Notice: Bet Floor Hit!")
                nextbet = betfloor
                print("Next bet set to: "..nextbet)
            end
            
            -- Check Profit Threshold
            if (currentprofit > profitmax) then
                print("[ALERT] PROFIT THRESHOLD REACHED")
                reset = true
            end


            -- Check Streak
            if (currentstreak == 6) then
                print('[ALERT] - Streak Trigger Reached - Resetting Seed')
                reset = true
            end

            -- Check Spins
            if (spincount < spinlimit) then
                spincount = spincount + 1
                print("SPIN COUNT: "..spincount.." / "..spinlimit)
            else    
                print("[ALERT] SPIN LIMIT REACHED - RESETTING")
                reset = true
            end
            
            
            if (reset == true) then
                print(" ")
                print("[NOTICE] RESETTING ALL")
                print("=============================>")
                nextbet   = basebet
                spincount = 0
                reset     = false 
                resetseed()
            end

            if (currency == "BTC") and (nextbet < minbtcbet) then
                print("Notice: Minimum BTC Bet reached.  Setting to "..minbtcbet)
                nextbet = minbtcbet
            end
        else
                print("[NOTICE] Skipping Threshold Checks During Recovery")
        end
    end


    ------------------------------------------------------
    ------------------ RECOVERY MODE ---------------------
    ------------------------------------------------------

    function recoverycheck()
        
        if (win==false) then
           inrecover = false 
        end
        
    -- Check if out of a plummet
        if (inplummet == true) and (currentstreak == 1) then
            inrecover = true    
            inrecspin = 0
            inplummet = false
         -- See if the plummet bank amt is more than next bet. If so, override it
            if (inplumbank > nextbet) then
                nextbet = inplumbank
            end
        end

     -- Recovery Mode High Stakes
     if (inrecover == true) then
            inrecspin = inrecspin + 1
            
            if (inrecspin < (inrecmax+1)) then
                print("     ")
                print("     ")
                print("     | RECOVERY MODE HIGH STAKES")
                print("     |")
                print("     |---> Recovery Spin "..inrecspin.." of "..inrecmax)
                print("     |---> Setting one off high stakes spin...")
            else
                print("     |---> Recovery Spin "..inrecspin.." of "..inrecmax)
                print("     |---> High Stakes Finished - Restoring bet to banked value of "..inplumbank)
                nextbet   = basebet
                inrecover = false
                reset     = true
            end
        end
    end

    ------------------------------------------------------
    ------------------- PLUMMET MODE ---------------------
    ------------------------------------------------------
    function plummetcheck()

        -- Check Plummet Status
        if (currentstreak == (plummetthresh+1)) then
            print(" ")
            print("     [ALERT] START OF PLUMMET")
            inplummet = true
        else
            inplummet = false
        end

        -- Check if start of plummet
        if (currentstreak == (plummetthresh+1)) then
            print("     |---> Beginning of plummet - Setting Bank")
            inplumbank = previousbet
            print("     |---> Setting Recovery Value: "..inplumbank)
        end


        -- What to do if plummeting
        if (inplummet == true) then
            print("     |---> Plummet Overriding Multiplier: "..plummultiplier.." Applying to bet...")
            nextbet = (previousbet*plummultiplier)
            print("     |---> Next bet now set to "..nextbet)
            print(" ")
        end
        
    ------------------------------------------------------
    --------------- UPDATE BASE BET MODE -----------------
    ------------------------------------------------------

        function updatebasebet()
            basebet = balance * (8 / 10000)
            sessionprofit = (balance - startbalance)
        end
       
    end

    ------------------------------------------------------
    ------------ ROUND FUNCTION FOR CONSOLE --------------
    ------------------------------------------------------

    function printval(valnum)
        return(string.format("%.12f",valnum))
    end
