using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;
//using UnityEngine.InputSystem;
using UnityEngine.XR;

public class PuzzelPoint : MonoBehaviour
{
    public Point[] pts;
    public Transform[] obstacles;
    public Point[] index;

    public Point startPt;
    public Point ExitePt;

    LineRenderer lr;
    private bool isOn;
    private List<Vector3> pointsOfLine = new List<Vector3>();
    private List<Point> PtOfLine = new List<Point>();
    public GameObject ob;
    // Get VR inputs
    private bool   hovered;
    InputDevice RightDevice;
    Get2DMovement mouse;
    //
    public Text text; // debuging
    private bool checkDir;
    private Vector3 currDir = Vector3.zero;
    private Vector3 end;


    bool win;
    [SerializeField] UnityEvent Solved;


    private void Start()
    {
        lr = this.GetComponent<LineRenderer>();
        foreach (Point p in pts)
        {
            if (p.startPt==true) { startPt = p; print("xx"); }
            break;
        }
        //
        List<InputDevice> D = new List<InputDevice>();

        InputDeviceCharacteristics RightCch = InputDeviceCharacteristics.Right | InputDeviceCharacteristics.Controller;

        InputDevices.GetDevicesWithCharacteristics(RightCch, D);
        if (D.Count > 0)
        {
            RightDevice = D[0];
        }
        
        //
    }

    public Vector2 EndLinePos(Vector3 mousePos)
    {
        
        Vector2 end;
        if (isOn && (currDir == Vector3.up || currDir == Vector3.down))
        {
            end = new Vector2(PtOfLine[PtOfLine.Count - 1].transform.position.x, mousePos.y);
        }
        else if (isOn && (currDir == Vector3.right || currDir == Vector3.left))
        {
            end = new Vector2(mousePos.x, PtOfLine[PtOfLine.Count - 1].transform.position.y);
        }
        else { end = mousePos; }

        return end;
    }

    public bool GetButtonDown()
    {
        if (hovered)
        {
            
            RightDevice.TryGetFeatureValue(CommonUsages.trigger, out float TriggerValue);
            if (TriggerValue > 0.2f)
            {
                return true;

            }
            else return false;
           
        }
        else
            return false;
    }


    private void Update()
    {
        if (!win)
        {
            Vector2 mousePos;
            //
            if (mouse == null) mouse = FindObjectOfType<Get2DMovement>();
            //
            if (mouse != null)
            {
                mousePos = mouse.transform.position;

                end = EndLinePos(mousePos);

                if (GetButtonDown())
                {
                    //ob.transform.position = end;
                    if (Vector2.Distance(startPt.transform.position, end) < 0.5f)
                    {
                        AddFirstpt();
                        text.text = "GO";

                    }
                }
                else
                {
                    clearAll();
                }

                if (isOn)
                {
                    pointsOfLine.Add(end);

                }

                //checkPos();

                
                if (isOn)
                {
                    foreach (Point p in pts)
                    {
                        if (!PtOfLine.Contains(p) && Vector2.Distance(p.transform.position, end) < 0.2f)
                        {
                            AddPt(p);
                            if (p.ExitePt) checkWin();
                            break;
                        }
                    }
                    ob.transform.position = new Vector3(end.x, end.y, startPt.transform.position.z);
                    if (Vector2.Distance(end, PtOfLine[PtOfLine.Count - 1].transform.position) > 0.35f) GetDirection(mousePos);
                    checkPos(mousePos);


                }


                

            }

        }
        DrawLine();
        if (pointsOfLine.Count != 0 && !win) pointsOfLine.RemoveAt(pointsOfLine.Count - 1);
    }


    public void GetDirection(Vector3 mp)
    {
        float alpha;
        if (!checkDir)
        {

            alpha = -Vector2.SignedAngle(mp - PtOfLine[PtOfLine.Count - 1].transform.position, Vector3.right);

            //Debug.Log(Mathf.Cos(alpha * Mathf.Deg2Rad));
            if (Mathf.Cos(alpha * Mathf.Deg2Rad) > 0)
            {
                if (Mathf.Abs(alpha) < 45) CheckDir(Vector2.right);
                else if (alpha > 45) CheckDir(Vector2.up);
                else CheckDir(Vector2.down);
            }
            else
            {
                alpha = Vector2.SignedAngle(mp - PtOfLine[PtOfLine.Count - 1].transform.position, Vector3.left);

                if (Mathf.Abs(alpha) < 45) CheckDir(Vector2.left);
                else if (alpha > 45) CheckDir(Vector2.up);
                else CheckDir(Vector2.down);
            }
            // print("On");
            checkDir = true;
        }
    }

    public void CheckDir(Vector3 Dir)
    {
        if (Dir == Vector3.up && PtOfLine[PtOfLine.Count - 1].UpNeighbor() == null)
        {
            clearAll(); print("Hit directio Ghalat");
        }
        else if (Dir == Vector3.up && PtOfLine[PtOfLine.Count - 1].UpNeighbor().isSelected) { clearAll(); Debug.Log("selected"); }
        if (Dir == Vector3.right && PtOfLine[PtOfLine.Count - 1].rightNeighbor() == null)
        {
            clearAll(); print("Hit directio Ghalat");
        }
        else if (Dir == Vector3.right && PtOfLine[PtOfLine.Count - 1].rightNeighbor().isSelected) { clearAll(); Debug.Log("selected"); }
        if (Dir == Vector3.down && PtOfLine[PtOfLine.Count - 1].DownNeighbor() == null)
        {
            clearAll(); print("Hit directio Ghalat");
        }
        else if (Dir == Vector3.down && PtOfLine[PtOfLine.Count - 1].DownNeighbor().isSelected) { clearAll(); Debug.Log("selected"); }
        if (Dir == Vector3.left && PtOfLine[PtOfLine.Count - 1].LeftNeighbor() == null)
        {
            clearAll(); print("Hit directio Ghalat");
        }
        else if (Dir == Vector3.left && PtOfLine[PtOfLine.Count - 1].LeftNeighbor().isSelected) { clearAll(); Debug.Log("selected"); }
        //        Debug.Log(Dir);
        currDir = Dir;
    }

    public void checkPos(Vector3 mou)
    {
        if (Vector3.Distance(mou, end) > 2f) { clearAll(); print(" Clean Hit ba3ati 3la l end"); }
    }



    public void DrawLine()
    {
        if (isOn || win)
        {
            lr.positionCount = pointsOfLine.Count;
            for (int i = 0; i < pointsOfLine.Count; i++)
            {
                Vector3 x = new Vector3(pointsOfLine[i].x, pointsOfLine[i].y, startPt.transform.position.z);
                lr.SetPosition(i, x);
            }
        }
    }
    public void AddFirstpt()
    {
        if (PtOfLine.Count == 0)
        {
            ob.SetActive(true);
            ob.GetComponent<EndPoint>().StopAnimate();
            startPt.isSelected = true;
            PtOfLine.Add(startPt);
            isOn = true;
            Vector3 start = startPt.transform.position;
            pointsOfLine.Add(start);
        }
    }

    public void AddPt(Point p)
    {
        
        currDir = Vector3.zero;
        PtOfLine.Add(p);
        p.isSelected = true;
        pointsOfLine.Insert(pointsOfLine.Count - 1, p.transform.position);
        checkDir = false;
    }

    public void clearAll()
    {
        if (!win)
        {
            ob.transform.position = startPt.transform.position;
            checkDir = false;
            isOn = false;
            pointsOfLine.Clear();
            foreach (Point p in PtOfLine) p.isSelected = false;
            PtOfLine.Clear();

            lr.positionCount = 0;
            currDir = Vector3.zero;
            ob.GetComponent<EndPoint>().AnimatePoint();
        }

    }

    public void Hovered()
    {
        hovered = true;
    }
    public void HoveredExit()
    {
        clearAll();
        hovered = false;
    }

    public void test()
    {
        //text.text =" "+A;
        //A++;
    }

    public void checkWin()
    {
        if (PtOfLine.Count >= index.Length)
        {
            bool win1 = true;
            foreach (Point p in index)
                if (!p.isSelected)
                {
                    win1 = false;
                    break;
                }
            if (win1)
            {
                win = true;
                Solved.Invoke();
            }
        }
    }

    
    
}
